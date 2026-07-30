import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/maps/maps_geocode_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../order_track_shared.dart';
import '../orders_l10n.dart';

/// Responsive breakpoints (logical pixels).
const double _breakpointTablet = 600;
const double _breakpointDesktop = 900;
const double _breakpointLarge = 1200;

/// Poll interval for real-time tracking when order is not delivered.
const Duration _trackPollInterval = Duration(seconds: 12);

/// Google Maps default route blue (similar to Maps directions).
const Color _kGoogleMapsRouteBlue = Color(0xFF4285F4);

/// Throttle polyline rebuilds during the route animation (native marker/polyline churn).
const int _kRoutePolylineQuantSteps = 40;

/// Quadratic Bézier in lat/lng plane (smooth arc from restaurant toward customer).
List<LatLng> _computeCurvedRoute(LatLng start, LatLng end, {int segments = 48}) {
  final midLat = (start.latitude + end.latitude) / 2;
  final midLng = (start.longitude + end.longitude) / 2;
  final dLat = end.latitude - start.latitude;
  final dLng = end.longitude - start.longitude;
  final dist = math.sqrt(dLat * dLat + dLng * dLng);
  if (dist < 1e-9) return [start, end];
  final perpLat = -dLng / dist;
  final perpLng = dLat / dist;
  final bulge = dist * 0.38;
  final ctrl = LatLng(midLat + perpLat * bulge, midLng + perpLng * bulge);
  final out = <LatLng>[];
  for (var i = 0; i <= segments; i++) {
    final t = i / segments;
    final u = 1 - t;
    final lat = u * u * start.latitude + 2 * u * t * ctrl.latitude + t * t * end.latitude;
    final lng = u * u * start.longitude + 2 * u * t * ctrl.longitude + t * t * end.longitude;
    out.add(LatLng(lat, lng));
  }
  return out;
}

/// Points along [path] from start to fraction [t] ∈ [0,1] (toward customer at t=1).
List<LatLng> _partialCurvePoints(List<LatLng> path, double t) {
  if (path.isEmpty) return path;
  if (path.length < 2) return List<LatLng>.from(path);
  t = t.clamp(0.0, 1.0);
  if (t <= 0) return [path.first, path[1]];
  final segLast = path.length - 2;
  final maxIndex = t * (path.length - 1);
  final i = maxIndex.floor().clamp(0, segLast).toInt();
  final frac = maxIndex - i;
  final out = path.sublist(0, i + 1);
  if (frac > 1e-8) {
    final a = path[i];
    final b = path[i + 1];
    out.add(LatLng(
      a.latitude + (b.latitude - a.latitude) * frac,
      a.longitude + (b.longitude - a.longitude) * frac,
    ));
  }
  return out;
}
// this map is removed from the code because it is not used

/// Maps linear controller 0→1 over [duration] to path fraction 0→1→0 (to customer, then back).
double _routeAnimT(double linear) {
  final v = linear.clamp(0.0, 1.0);
  if (v <= 0.5) {
    return Curves.easeInOut.transform(v * 2);
  }
  return 1.0 - Curves.easeInOut.transform((v - 0.5) * 2);
}

class OrderTrackScreen extends StatefulWidget {
  const OrderTrackScreen({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen>
    with TickerProviderStateMixin {
  OrderModel? _order;
  bool _loading = true;
  bool _trackingLoadFailed = false;

  /// Resolved from API or geocoding so the map shows restaurant → delivery route.
  double? _resolvedRestaurantLat;
  double? _resolvedRestaurantLng;
  double? _resolvedDeliveryLat;
  double? _resolvedDeliveryLng;

  late AnimationController _entranceController;
  late List<Animation<double>> _animations;
  GoogleMapController? _googleMapController;
  final MapsGeocodeService _mapsGeocode = MapsGeocodeService();
  /// Polls track API for real-time driver position when order is not delivered.
  Timer? _trackPollTimer;
  Worker? _localeWorker;

  /// Restaurant → delivery: sampled curved path (map plane).
  List<LatLng> _routeCurvePath = const [];

  /// 3s loop: draw along curve toward customer, then ease back toward restaurant.
  late final AnimationController _routeDrawController;
  int _lastRoutePolylineStep = -1;

  /// Default Google Maps–style pins (no custom bitmaps).
  final BitmapDescriptor _pinRestaurant = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  final BitmapDescriptor _pinUser = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  final BitmapDescriptor _pinDriver = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  void _onRouteDrawTick() {
    if (!mounted) return;
    final raw = _routeAnimT(_routeDrawController.value);
    final step = (raw * _kRoutePolylineQuantSteps).floor().clamp(0, _kRoutePolylineQuantSteps);
    if (step == _lastRoutePolylineStep) return;
    _lastRoutePolylineStep = step;
    setState(() {});
  }

  void _startRouteAnimation() {
    if (_routeCurvePath.length < 2) return;
    _lastRoutePolylineStep = -1;
    _routeDrawController
      ..reset()
      ..repeat();
  }

  void _stopRouteAnimation() {
    _routeDrawController.stop();
    _routeDrawController.reset();
    _lastRoutePolylineStep = -1;
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) setState(() {});
      });
    }
    _routeDrawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_onRouteDrawTick);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animations = List.generate(6, (i) {
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          (i * 0.1).clamp(0.0, 0.7),
          (0.25 + i * 0.1).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );
    });
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    setState(() {
      _loading = true;
      _trackingLoadFailed = false;
      _resolvedRestaurantLat = null;
      _resolvedRestaurantLng = null;
      _resolvedDeliveryLat = null;
      _resolvedDeliveryLng = null;
      _routeCurvePath = const [];
    });
    _stopRouteAnimation();
    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    OrderModel? order = await ctrl.trackOrder(widget.orderId);
    if (!mounted) return;
    if (order != null) {
      final hasRestaurantCoords = order.restaurantLatitude != null && order.restaurantLongitude != null;
      final hasDeliveryCoords = order.deliveryLatitude != null && order.deliveryLongitude != null;
      final needsAddressForDisplay = (order.deliveryAddress == null || order.deliveryAddress!.trim().isEmpty) ||
          (order.restaurantAddress == null || order.restaurantAddress!.trim().isEmpty);
      if (!hasRestaurantCoords || !hasDeliveryCoords) {
        final fullOrder = await ctrl.getOrderById(widget.orderId);
        if (fullOrder != null && mounted) {
          await _resolveAddressesToCoordinates(fullOrder);
          order = fullOrder.copyWith(driver: order.driver);
        }
      } else {
        _resolvedRestaurantLat = order.restaurantLatitude;
        _resolvedRestaurantLng = order.restaurantLongitude;
        _resolvedDeliveryLat = order.deliveryLatitude;
        _resolvedDeliveryLng = order.deliveryLongitude;
        if (needsAddressForDisplay) {
          final fullOrder = await ctrl.getOrderById(widget.orderId);
          if (fullOrder != null && mounted) {
            order = fullOrder.copyWith(driver: order.driver);
          }
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
      _trackingLoadFailed = order == null;
      if (order != null && _hasTwoDistinctPoints) {
        _routeCurvePath = _computeCurvedRoute(
          LatLng(_restaurantLat, _restaurantLng),
          LatLng(_deliveryLat, _deliveryLng),
        );
      } else {
        _routeCurvePath = const [];
      }
    });
    if (order != null) {
      if (_routeCurvePath.length >= 2) {
        _startRouteAnimation();
      } else {
        _stopRouteAnimation();
      }
      _entranceController.forward();
      _startTrackingPoll();
    }
  }

  /// Refresh track data (order status + driver position) without full reload.
  Future<void> _refreshTrack() async {
    if (_order == null || !mounted) return;
    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    try {
      final updated = await ctrl.trackOrder(widget.orderId);
      if (!mounted) return;
      if (updated != null) {
        setState(() {
          _order = updated;
          final s = updated.status.toLowerCase().replaceAll(' ', '_');
          if (s == 'delivered' || s == 'cancelled') {
            _trackPollTimer?.cancel();
            _trackPollTimer = null;
          }
        });
      }
    } catch (_) {}
  }

  void _startTrackingPoll() {
    _trackPollTimer?.cancel();
    final status = _order?.status.toLowerCase().replaceAll(' ', '_') ?? '';
    if (status == 'delivered' || status == 'cancelled') return;
    _trackPollTimer = Timer.periodic(_trackPollInterval, (_) => _refreshTrack());
  }

  /// Fit bounds with smooth camera animation (native driver animation).
  Future<void> _frameRestaurantToDelivery() async {
    final controller = _googleMapController;
    if (controller == null || !mounted || !_hasTwoDistinctPoints) return;
    var minLat = math.min(_restaurantLat, _deliveryLat);
    var maxLat = math.max(_restaurantLat, _deliveryLat);
    var minLng = math.min(_restaurantLng, _deliveryLng);
    var maxLng = math.max(_restaurantLng, _deliveryLng);
    const pad = 0.004;
    if ((maxLat - minLat).abs() < 1e-5) {
      minLat -= pad;
      maxLat += pad;
    }
    if ((maxLng - minLng).abs() < 1e-5) {
      minLng -= pad;
      maxLng += pad;
    }
    // Extra margin so the map is not framed too tight (more “zoomed out”).
    const geoMargin = 0.0022;
    minLat -= geoMargin;
    maxLat += geoMargin;
    minLng -= geoMargin;
    maxLng += geoMargin;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (_) {
      if (!mounted) return;
      try {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(_mapCenter, 13));
      } catch (_) {}
    }
  }

  Future<void> _mapZoomIn() async {
    final controller = _googleMapController;
    if (controller == null || !mounted) return;
    try {
      await controller.animateCamera(CameraUpdate.zoomIn());
    } catch (_) {}
  }

  Future<void> _mapZoomOut() async {
    final controller = _googleMapController;
    if (controller == null || !mounted) return;
    try {
      await controller.animateCamera(CameraUpdate.zoomOut());
    } catch (_) {}
  }

  /// Opens Google Maps (app or browser) with driving directions: restaurant → delivery.
  Future<void> _openDirectionsToDelivery() async {
    if (!_hasTwoDistinctPoints) return;
    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      <String, String>{
        'api': '1',
        'origin': '$_restaurantLat,$_restaurantLng',
        'destination': '$_deliveryLat,$_deliveryLng',
        'travelmode': 'driving',
      },
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.orderTrackDirectionsCouldNotOpen,
              style: FontHelper.getTextStyle(
                text: l10n.orderTrackDirectionsCouldNotOpen,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.orderTrackDirectionsCouldNotOpen,
            style: FontHelper.getTextStyle(
              text: l10n.orderTrackDirectionsCouldNotOpen,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  /// Geocode restaurant and delivery addresses when API does not provide lat/lng.
  Future<void> _resolveAddressesToCoordinates(OrderModel order) async {
    final defaultCity = AfghanistanRegion.geocodingCityLine;
    double? restLat = order.restaurantLatitude;
    double? restLng = order.restaurantLongitude;
    double? delLat = order.deliveryLatitude;
    double? delLng = order.deliveryLongitude;

    if (restLat == null || restLng == null) {
      final restAddress = order.restaurantAddress?.trim().isNotEmpty == true
          ? '${order.restaurantAddress}, $defaultCity'
          : '${OrdersL10n.restaurantTitle(context, AppLocalizations.of(context)!, order)}, $defaultCity';
      final restHit = await _geocodeAddress(restAddress);
      if (restHit != null) {
        restLat = restHit.lat;
        restLng = restHit.lng;
      }
    }
    if (delLat == null || delLng == null) {
      final delAddress = order.deliveryAddress?.trim().isNotEmpty == true
          ? '${order.deliveryAddress}, $defaultCity'
          : (order.deliveryName != null ? '${order.deliveryName}, $defaultCity' : null);
      if (delAddress != null) {
        final delHit = await _geocodeAddress(delAddress);
        if (delHit != null) {
          delLat = delHit.lat;
          delLng = delHit.lng;
        }
      }
    }

    if (mounted) {
      setState(() {
        _resolvedRestaurantLat = restLat ?? AfghanistanRegion.defaultMapLatitude;
        _resolvedRestaurantLng = restLng ?? AfghanistanRegion.defaultMapLongitude;
        _resolvedDeliveryLat = delLat ?? AfghanistanRegion.defaultMapLatitude;
        _resolvedDeliveryLng = delLng ?? AfghanistanRegion.defaultMapLongitude;
        if (_hasTwoDistinctPoints) {
          _routeCurvePath = _computeCurvedRoute(
            LatLng(_restaurantLat, _restaurantLng),
            LatLng(_deliveryLat, _deliveryLng),
          );
        } else {
          _routeCurvePath = const [];
        }
      });
      if (_routeCurvePath.length >= 2) {
        _startRouteAnimation();
      } else {
        _stopRouteAnimation();
      }
      final rLat = _resolvedRestaurantLat!;
      final rLng = _resolvedRestaurantLng!;
      final dLat = _resolvedDeliveryLat!;
      final dLng = _resolvedDeliveryLng!;
      final samePoint = (rLat - dLat).abs() < 0.0001 && (rLng - dLng).abs() < 0.0001;
      if (!samePoint) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_frameRestaurantToDelivery());
        });
      }
    }
  }

  @override
  void dispose() {
    _localeWorker?.dispose();
    _trackPollTimer?.cancel();
    _routeDrawController.removeListener(_onRouteDrawTick);
    _routeDrawController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<({double lat, double lng})?> _geocodeAddress(String address) async {
    final fromServer = await _mapsGeocode.geocode(address);
    if (fromServer != null) return fromServer;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return (lat: locations.first.latitude, lng: locations.first.longitude);
      }
    } catch (_) {}
    return null;
  }

  static String _snippetForMapInfo(String text) {
    final t = text.trim();
    if (t.length <= 100) return t;
    return '${t.substring(0, 97)}...';
  }

  String _restaurantLocationName(BuildContext context, OrderModel? order, AppLocalizations l10n) {
    if (order == null) return l10n.restaurantDefaultName;
    return OrdersL10n.restaurantTitle(context, l10n, order);
  }

  /// Customer label: prefer contact/delivery name, else address, else generic.
  String _customerLocationName(OrderModel? order, AppLocalizations l10n) {
    if (order == null) return l10n.yourLocation;
    final name = order.deliveryName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final addr = order.deliveryAddress?.trim();
    if (addr != null && addr.isNotEmpty) return addr;
    return l10n.yourLocation;
  }

  /// Second line on delivery marker when title is the customer name and address differs.
  String _customerMapSnippet(OrderModel? order, String customerTitle) {
    if (order == null) return '';
    final addr = order.deliveryAddress?.trim();
    if (addr == null || addr.isEmpty) return '';
    if (addr == customerTitle) return '';
    return _snippetForMapInfo(addr);
  }

  double get _restaurantLat =>
      _resolvedRestaurantLat ?? _order?.restaurantLatitude ?? AfghanistanRegion.defaultMapLatitude;
  double get _restaurantLng =>
      _resolvedRestaurantLng ?? _order?.restaurantLongitude ?? AfghanistanRegion.defaultMapLongitude;
  double get _deliveryLat =>
      _resolvedDeliveryLat ?? _order?.deliveryLatitude ?? AfghanistanRegion.defaultMapLatitude;
  double get _deliveryLng =>
      _resolvedDeliveryLng ?? _order?.deliveryLongitude ?? AfghanistanRegion.defaultMapLongitude;

  bool get _hasTwoDistinctPoints {
    const eps = 0.0001;
    return ((_restaurantLat - _deliveryLat).abs() > eps) || ((_restaurantLng - _deliveryLng).abs() > eps);
  }

  LatLng get _mapCenter => LatLng(
        (_restaurantLat + _deliveryLat) / 2,
        (_restaurantLng + _deliveryLng) / 2,
      );

  int get _currentStepIndex {
    if (_order == null) return 0;
    return orderTrackStepIndexFromStatus(_order!.status);
  }

  double _horizontalPadding(double width) {
    if (width >= _breakpointLarge) return 48;
    if (width >= _breakpointDesktop) return 32;
    if (width >= _breakpointTablet) return 24;
    return 16;
  }

  double _mapHeight(double width) {
    if (width >= _breakpointLarge) return 440;
    if (width >= _breakpointDesktop) return 380;
    if (width >= _breakpointTablet) return 320;
    if (width < 360) return 252;
    if (width < 400) return 268;
    return 280;
  }

  @override
  Widget build(BuildContext context) {
    final _ = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>().localeRx.value
        : null;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _breakpointDesktop;
    final gutter = width < _breakpointTablet ? context.pageHorizontalPadding : _horizontalPadding(width);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPad = (width >= _breakpointTablet ? 32.0 : 24.0) + bottomInset;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MaxWidthBody(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildAppBar(context, gutter),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_trackingLoadFailed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(context),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  width >= _breakpointTablet ? 24 : 16,
                  gutter,
                  bottomPad,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    isWide ? _buildWideLayout(context, width) : _buildNarrowLayout(context, width),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _trackStatusLabel(BuildContext context, String key) {
    return localizedOrderTrackStatus(context, key, key);
  }

  Widget _buildAppBar(BuildContext context, [double? horizontalPadding]) {
    final padding = horizontalPadding ?? 16;
    final l10n = AppLocalizations.of(context)!;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 400;
    return SliverList(
      delegate: SliverChildListDelegate([
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? padding * 0.35 : padding * 0.5, 8, padding, compact ? 12 : 16),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 6 : 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: compact ? 24 : 28,
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.backToOrderDetails,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: l10n.backToOrderDetails,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: compact ? 15.0 : 16.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hPad = context.pageHorizontalPadding;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 400;
    final narrow = w < 360;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: narrow ? 52 : (compact ? 58 : 64),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            l10n.couldNotLoadTracking,
            textAlign: TextAlign.center,
            style: FontHelper.getTextStyle(
              text: l10n.couldNotLoadTracking,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 15.0 : 16.0,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          FilledButton.icon(
            onPressed: _loadTrack,
            icon: Icon(Icons.refresh_rounded, size: compact ? 20 : 24),
            label: Text(
              l10n.retry,
              style: FontHelper.getTextStyle(
                text: l10n.retry,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, double width) {
    final gap = width >= _breakpointLarge ? 32.0 : 24.0;
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _animatedCard(0, _buildMapCard(context, width)),
            ),
            SizedBox(width: gap),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _animatedCard(1, _buildOrderStatusCard(context, width)),
                  SizedBox(height: gap),
                  _animatedCard(2, _buildRestaurantCard(context, width)),
                  SizedBox(height: gap),
                  _animatedCard(3, _buildDriverCard(context, width)),
                  SizedBox(height: gap),
                  _animatedCard(4, _buildDeliveryAddressCard(context, width)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, double width) {
    final gap = width >= _breakpointTablet ? 20.0 : 16.0;
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _animatedCard(0, _buildMapCard(context, width)),
            SizedBox(height: gap),
            _animatedCard(1, _buildOrderStatusCard(context, width)),
            SizedBox(height: gap),
            _animatedCard(2, _buildRestaurantCard(context, width)),
            SizedBox(height: gap),
            _animatedCard(3, _buildDriverCard(context, width)),
            SizedBox(height: gap),
            _animatedCard(4, _buildDeliveryAddressCard(context, width)),
            SizedBox(height: width < 400 ? 8 : (width >= _breakpointTablet ? 32.0 : 24.0)),
          ],
        );
      },
    );
  }

  Widget _animatedCard(int index, Widget child) {
    if (index >= _animations.length) return child;
    final anim = _animations[index];
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
      child: child,
    );
  }

  /// Curved path animated toward customer then back (one cycle = 3s); map-plane segments.
  Set<Polyline> _routePolylines() {
    if (_routeCurvePath.length < 2) return {};
    final t = _routeAnimT(_routeDrawController.value);
    var pts = _partialCurvePoints(_routeCurvePath, t);
    if (pts.length < 2) {
      pts = [_routeCurvePath.first, _routeCurvePath[1]];
    }
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: pts,
        color: _kGoogleMapsRouteBlue,
        width: 4,
        geodesic: false,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 1,
      ),
    };
  }

  Widget _buildMapCard(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order;
    final restaurantPoint = LatLng(_restaurantLat, _restaurantLng);
    final deliveryPoint = LatLng(_deliveryLat, _deliveryLng);
    final driver = order?.driver;
    final driverPoint = (driver?.latitude != null && driver?.longitude != null)
        ? LatLng(driver!.latitude!, driver.longitude!)
        : null;
    final fromLabel = order?.restaurantAddress?.trim().isNotEmpty == true
        ? order!.restaurantAddress!
        : (order != null ? OrdersL10n.restaurantTitle(context, l10n, order) : l10n.restaurantDefaultName);
    final hasDeliveryAddress = order != null &&
        order.deliveryAddress != null &&
        order.deliveryAddress!.trim().isNotEmpty;
    final hasDeliveryName = order?.deliveryName?.trim().isNotEmpty == true;
    final toLabel = hasDeliveryAddress
        ? order.deliveryAddress!
        : (hasDeliveryName && order != null ? order.deliveryName! : l10n.yourLocation);
    final mapH = _mapHeight(width);

    final restaurantName = _restaurantLocationName(context, order, l10n);
    final customerName = _customerLocationName(order, l10n);
    final restaurantSnippet = order?.restaurantAddress?.trim().isNotEmpty == true
        ? _snippetForMapInfo(order!.restaurantAddress!)
        : '';
    final customerSnippet = _customerMapSnippet(order, customerName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(width >= _breakpointTablet ? 16 : 12),
          child: SizedBox(
            height: mapH,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                GoogleMap(
                  // Default Google Maps look (no custom JSON styling).
                  style: null,
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 10,
                  ),
                  onMapCreated: (c) {
                    _googleMapController = c;
                    if (!mounted) return;
                    if (!_hasTwoDistinctPoints) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      unawaited(_frameRestaurantToDelivery());
                    });
                  },
                  mapType: MapType.normal,
                  mapToolbarEnabled: true,
                  // Native zoom widgets are unreliable on iOS / behind overlays; we use custom buttons.
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  polylines: _routePolylines(),
                  markers: {
                    Marker(
                      markerId: const MarkerId('restaurant'),
                      position: restaurantPoint,
                      anchor: const Offset(0.5, 1.0),
                      zIndexInt: 20,
                      icon: _pinRestaurant,
                      infoWindow: InfoWindow(
                        title: restaurantName,
                        snippet: restaurantSnippet,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId('delivery'),
                      position: deliveryPoint,
                      anchor: const Offset(0.5, 0.5),
                      zIndexInt: 25,
                      icon: _pinUser,
                      infoWindow: InfoWindow(
                        title: customerName,
                        snippet: customerSnippet,
                      ),
                    ),
                    if (driverPoint != null)
                      Marker(
                        markerId: const MarkerId('driver'),
                        position: driverPoint,
                        anchor: const Offset(0.5, 0.5),
                        zIndexInt: 22,
                        icon: _pinDriver,
                        infoWindow: InfoWindow(title: l10n.mapMarkerDriver),
                      ),
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.orderTrackZoomIn,
                              onPressed: () => unawaited(_mapZoomIn()),
                              icon: const Icon(Icons.add_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            IconButton(
                              tooltip: l10n.orderTrackZoomOut,
                              onPressed: () => unawaited(_mapZoomOut()),
                              icon: const Icon(Icons.remove_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        child: IconButton(
                          tooltip: l10n.orderTrackDirections,
                          onPressed: _hasTwoDistinctPoints
                              ? () => unawaited(_openDirectionsToDelivery())
                              : null,
                          icon: Icon(
                            Icons.directions_rounded,
                            color: _hasTwoDistinctPoints
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.storefront_outlined, size: 18, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  restaurantName,
                                  style: FontHelper.getTextStyle(
                                    text: restaurantName,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.person_pin_circle_outlined, size: 18, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: FontHelper.getTextStyle(
                                    text: customerName,
                                    languageCode: Get.find<LocaleController>().locale.languageCode,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: width >= _breakpointTablet ? 12 : 10),
    Container(
          padding: EdgeInsets.symmetric(
            horizontal: width >= _breakpointTablet ? 16 : 12,
            vertical: width >= _breakpointTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(width >= _breakpointTablet ? 12 : 10),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 0),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.routeFromLabel,
                                    style: FontHelper.getTextStyle(
                                      text: l10n.routeFromLabel,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fromLabel,
                                    style: FontHelper.getTextStyle(
                                      text: fromLabel,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 0),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.routeToLabel,
                                    style: FontHelper.getTextStyle(
                                      text: l10n.routeToLabel,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    toLabel,
                                    style: FontHelper.getTextStyle(
                                      text: toLabel,
                                      languageCode: Get.find<LocaleController>().locale.languageCode,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  double _cardPadding(double width) {
    if (width >= _breakpointDesktop) return 24;
    if (width >= _breakpointTablet) return 20;
    if (width < 360) return 14;
    return 16;
  }

  Widget _buildOrderStatusCard(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final currentIndex = _currentStepIndex;

    return _Card(
      padding: _cardPadding(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.orderNumberLabel('${order.orderNumber ?? order.id}'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontHelper.getTextStyle(
                    text: l10n.orderNumberLabel('${order.orderNumber ?? order.id}'),
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _StatusChip(status: order.status),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < _breakpointTablet;
              final content = Row(
                mainAxisSize: isNarrow ? MainAxisSize.min : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < kOrderTrackSteps.length; i++) ...[
                    if (i > 0 && !isNarrow)
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 36,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              height: 3,
                              decoration: BoxDecoration(
                                color: i <= currentIndex
                                    ? AppColors.success
                                    : Theme.of(context).colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (i > 0 && isNarrow)
                      SizedBox(
                        height: 36,
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: i <= currentIndex
                                  ? AppColors.success
                                  : Theme.of(context).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    if (isNarrow)
                      _buildStepItem(
                        context,
                        _trackStatusLabel(context, kOrderTrackSteps[i]['key']!),
                        kOrderTrackSteps[i]['key']!,
                        i <= currentIndex,
                        i == currentIndex,
                        i,
                        labelSlotWidth: (constraints.maxWidth * 0.18).clamp(64.0, 96.0).toDouble(),
                      )
                    else
                      Expanded(
                        flex: 2,
                        child: _buildStepItem(
                          context,
                          _trackStatusLabel(context, kOrderTrackSteps[i]['key']!),
                          kOrderTrackSteps[i]['key']!,
                          i <= currentIndex,
                          i == currentIndex,
                          i,
                          expandLabel: true,
                        ),
                      ),
                    if (i < kOrderTrackSteps.length - 1 && isNarrow) const SizedBox(width: 4),
                  ],
                ],
              );
              if (isNarrow) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: content,
                );
              }
              return content;
            },
          ),
          if ((order.estimatedDeliveryTime != null && order.estimatedDeliveryTime!.isNotEmpty) ||
              (order.deliveryTime != null && order.deliveryTime!.isNotEmpty)) ...[
            SizedBox(height: width < 400 ? 16 : 20),
            Builder(
              builder: (context) {
                final deliveryCaption = OrdersL10n.deliveryTimeCaption(context, order);
                return Container(
                  padding: EdgeInsets.all(width < 400 ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.estimatedDeliveryTime,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: l10n.estimatedDeliveryTime,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deliveryCaption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: deliveryCaption,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    String label,
    String key,
    bool isComplete,
    bool isCurrent,
    int index, {
    bool expandLabel = false,
    double? labelSlotWidth,
  }) {
    IconData icon;
    switch (key) {
      case 'pending':
        icon = Icons.schedule_rounded;
        break;
      case 'confirmed':
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'preparing':
        icon = Icons.restaurant_rounded;
        break;
      case 'ready':
        icon = Icons.inventory_2_rounded;
        break;
      case 'picked_up':
        icon = Icons.two_wheeler_rounded;
        break;
      case 'on_the_way':
        icon = Icons.local_shipping_rounded;
        break;
      case 'delivered':
        icon = Icons.home_rounded;
        break;
      default:
        icon = Icons.circle_rounded;
    }

    final labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: expandLabel ? 3 : 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: FontHelper.getTextStyle(
        text: label,
        languageCode: Get.find<LocaleController>().locale.languageCode,
        fontSize: 10.0,
        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
        color: isCurrent ? AppColors.success : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isComplete ? AppColors.success : Theme.of(context).colorScheme.outlineVariant,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isComplete && !isCurrent
              ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 20)
              : Center(
                  child: isCurrent
                      ? Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 18)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
        ),
        const SizedBox(height: 6),
        if (expandLabel)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: labelWidget,
            ),
          )
        else
          SizedBox(
            width: labelSlotWidth ?? 64,
            child: labelWidget,
          ),
      ],
    );
  }

  Widget _buildRestaurantCard(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');

    return _Card(
      padding: _cardPadding(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mapMarkerRestaurant,
            style: FontHelper.getTextStyle(
              text: l10n.mapMarkerRestaurant,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: order.restaurantImage != null &&
                        order.restaurantImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: order.restaurantImage!.startsWith('http')
                              ? order.restaurantImage!
                              : '$base${order.restaurantImage}',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primaryLight,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primaryLight,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrdersL10n.restaurantTitle(context, l10n, order),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontHelper.getTextStyle(
                        text: OrdersL10n.restaurantTitle(context, l10n, order),
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (order.restaurantAddress != null &&
                        order.restaurantAddress!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        order.restaurantAddress!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.getTextStyle(
                          text: order.restaurantAddress!,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final driver = order.driver;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    final isCompact = width < _breakpointTablet;
    final avatarSize = width >= _breakpointDesktop ? 56.0 : (width >= _breakpointTablet ? 52.0 : 48.0);

    return _Card(
      padding: _cardPadding(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final badge = driver != null &&
                      (driver.latitude != null && driver.longitude != null)
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            l10n.trackDriverLive,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontHelper.getTextStyle(
                              text: l10n.trackDriverLive,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null;
              if (constraints.maxWidth < 320 && badge != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourDriver,
                      style: FontHelper.getTextStyle(
                        text: l10n.yourDriver,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    badge,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l10n.yourDriver,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontHelper.getTextStyle(
                        text: l10n.yourDriver,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Flexible(child: badge),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: isCompact ? 12 : 16),
          if (driver != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  child: driver.avatarUrl != null && driver.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: driver.avatarUrl!.startsWith('http')
                              ? driver.avatarUrl!
                              : '$base${driver.avatarUrl}',
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _driverPlaceholder(driver.name, avatarSize),
                          errorWidget: (_, __, ___) => _driverPlaceholder(driver.name, avatarSize),
                        )
                      : _driverPlaceholder(driver.name, avatarSize),
                ),
                SizedBox(width: isCompact ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: FontHelper.getTextStyle(
                          text: driver.name,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (driver.phone != null && driver.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SelectableText(
                          driver.phone!,
                          style: FontHelper.getTextStyle(
                            text: driver.phone!,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                        ),
                      ],
                      if (driver.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: AppColors.rating),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                driver.rating!.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (driver.vehicleType != null || driver.vehiclePlate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${driver.vehicleType ?? l10n.vehicleDefault} ${driver.vehiclePlate ?? ''}'.trim(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (driver.phone != null && driver.phone!.isNotEmpty) ...[
              SizedBox(height: isCompact ? 12 : 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse('tel:${driver.phone}')),
                  icon: Icon(Icons.phone_rounded, size: 20),
                  label: Text(
                    l10n.callDriver,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontHelper.getTextStyle(
                      text: l10n.callDriver,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 12),
                  ),
                ),
              ),
            ],
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_search_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.lookingForDriver,
                      style: FontHelper.getTextStyle(
                        text: l10n.lookingForDriver,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _driverPlaceholder(String name, [double size = 56]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: FontHelper.getTextStyle(
            text: name.isNotEmpty ? name[0].toUpperCase() : '?',
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;

    return _Card(
      padding: _cardPadding(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deliveryAddressSection,
            style: FontHelper.getTextStyle(
              text: l10n.deliveryAddressSection,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.deliveryName != null &&
                          order.deliveryName!.trim().isNotEmpty)
                        Text(
                          order.deliveryName!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (order.deliveryAddress != null &&
                          order.deliveryAddress!.trim().isNotEmpty) ...[
                        if (order.deliveryName != null &&
                            order.deliveryName!.trim().isNotEmpty)
                          const SizedBox(height: 4),
                        Text(
                          order.deliveryAddress!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        if (order.deliveryName != null &&
                            order.deliveryName!.trim().isNotEmpty)
                          const SizedBox(height: 4),
                        Text(
                          l10n.yourLocation,
                          style: FontHelper.getTextStyle(
                            text: l10n.yourLocation,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (order.deliveryInstructions != null &&
                          order.deliveryInstructions!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          order.deliveryInstructions!,
                          style: FontHelper.getTextStyle(
                            text: order.deliveryInstructions!,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final p = padding ?? 20;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(p),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  static const _statusColors = {
    'pending': Color(0xFFFEF3C7),
    'confirmed': Color(0xFFDBEAFE),
    'preparing': Color(0xFFEDE9FE),
    'ready': Color(0xFFE0E7FF),
    'picked_up': Color(0xFFCFFAFE),
    'on_the_way': Color(0xFFCCFBF1),
    'delivered': Color(0xFFD1FAE5),
    'cancelled': Color(0xFFFEE2E2),
  };

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    final bg = _statusColors[normalized] ?? Theme.of(context).colorScheme.outlineVariant;
    final compact = MediaQuery.sizeOf(context).width < 400;

    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 148 : 200),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 5 : 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        localizedOrderTrackStatus(context, normalized, status),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: FontHelper.getTextStyle(
          text: localizedOrderTrackStatus(context, normalized, status),
          languageCode: Get.find<LocaleController>().locale.languageCode,
          fontSize: compact ? 11.5 : 13.0,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
