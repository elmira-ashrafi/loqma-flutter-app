import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/utils/error_parser.dart';
import '../models/driver_models.dart';
import '../services/driver_service.dart';

class DriverController extends GetxController {
  DriverController({DriverService? service}) : _service = service ?? DriverService();

  final DriverService _service;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final Rx<DriverDashboardData?> dashboard = Rx<DriverDashboardData?>(null);
  final RxBool isOnline = false.obs;

  final RxList<DriverOrder> orders = <DriverOrder>[].obs;
  final RxBool isLoadingOrders = true.obs;
  final RxString ordersError = ''.obs;
  final RxString ordersStatusFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    loadOrders();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _service.getDashboard();
      dashboard.value = data;
      isOnline.value = data.driver.isOnline;
    } on DioException catch (e) {
      error.value = parseDioError(e);
    } catch (_) {
      error.value = 'Could not load driver dashboard.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => loadDashboard();

  Future<void> toggleOnlineStatus() async {
    final current = isOnline.value;
    try {
      final result = await _service.toggleOnline(!current);
      isOnline.value = result;
      final currentDash = dashboard.value;
      if (currentDash != null) {
        dashboard.value = currentDash.copyWith(
          driver: currentDash.driver.copyWith(isOnline: result),
        );
      }
    } catch (_) {
      isOnline.value = current;
    }
  }

  Future<void> loadOrders({String? status}) async {
    isLoadingOrders.value = true;
    ordersError.value = '';
    try {
      final list = await _service.getOrders(status: status ?? ordersStatusFilter.value);
      orders.assignAll(list);
    } on DioException catch (e) {
      ordersError.value = parseDioError(e);
    } catch (_) {
      ordersError.value = 'Could not load orders.';
    } finally {
      isLoadingOrders.value = false;
    }
  }

  void setOrdersStatusFilter(String? status) {
    ordersStatusFilter.value = status ?? '';
    loadOrders(status: status);
  }

  Future<void> acceptOrder(int id) async {
    await _service.acceptOrder(id);
    await loadDashboard();
    await loadOrders();
  }

  Future<void> updateOrderStatus(int id, String status) async {
    await _service.updateOrderStatus(id, status);
    await loadDashboard();
    await loadOrders();
  }
}

