import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../l10n/app_localizations.dart';

/// In-app HesabPay checkout. Detects return URLs and `loqma://` deep link redirects.
class HesabPayWebViewScreen extends StatefulWidget {
  const HesabPayWebViewScreen({
    super.key,
    required this.initialUrl,
  });

  final String initialUrl;

  @override
  State<HesabPayWebViewScreen> createState() => _HesabPayWebViewScreenState();
}

class _HesabPayWebViewScreenState extends State<HesabPayWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _handledCallback = false;

  static const _allowedHosts = <String>{
    'hesab.com',
    'api.hesab.com',
    'api-sandbox.hesab.com',
    'loqma.delivery',
    'www.loqma.delivery',
  };

  bool _isAllowedNavigation(Uri uri) {
    if (uri.scheme == 'loqma') {
      return uri.host == 'payment-success' || uri.host == 'payment-fail';
    }
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return false;
    }
    final host = uri.host.toLowerCase();
    return _allowedHosts.contains(host) ||
        _allowedHosts.any((allowed) => host.endsWith('.$allowed'));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'LoqmaPayment',
        onMessageReceived: (msg) {
          if (_handledCallback) return;
          if (!_isPaymentSuccessMessage(msg.message)) return;
          _handledCallback = true;
          if (mounted) Navigator.of(context).pop<bool>(true);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && !_isAllowedNavigation(uri)) {
              return NavigationDecision.prevent;
            }
            final decision = _handleCallbackUrl(request.url);
            return decision ?? NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => _loading = true);
            _tryHandleCallback(url);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _loading = false);
            _tryHandleCallback(url);
            _injectPaymentSuccessBridge();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  bool _isPaymentSuccessMessage(String raw) {
    final trimmed = raw.trim();
    if (trimmed == 'paymentSuccess') {
      return true;
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return decoded['type']?.toString() == 'paymentSuccess';
      }
    } catch (_) {}
    return false;
  }

  Future<void> _injectPaymentSuccessBridge() async {
    const script = '''
      (function () {
        if (window.__loqmaPaymentBound) return;
        window.__loqmaPaymentBound = true;
        window.addEventListener('message', function(event) {
          try {
            var data = event && event.data ? event.data : null;
            if (!data) return;
            if (typeof data === 'object' && data.type === 'paymentSuccess') {
              LoqmaPayment.postMessage(JSON.stringify(data));
            }
          } catch (e) {}
        });
      })();
    ''';
    await _controller.runJavaScript(script);
  }

  /// Returns [NavigationDecision.prevent] if we handled and popped.
  NavigationDecision? _handleCallbackUrl(String url) {
    if (_handledCallback) return NavigationDecision.prevent;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.scheme == 'loqma' && uri.host == 'payment-success') {
      _handledCallback = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop<bool>(true);
      });
      return NavigationDecision.prevent;
    }
    if (uri.scheme == 'loqma' && uri.host == 'payment-fail') {
      _handledCallback = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop<bool>(false);
      });
      return NavigationDecision.prevent;
    }

    return null;
  }

  void _tryHandleCallback(String url) {
    if (_handledCallback) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final path = uri.path.toLowerCase();
    final host = uri.host.toLowerCase();

    final isApiCallback = path.contains('/api/payment/callback');
    final isHttpsSuccess =
        host.contains('loqma.delivery') && path.contains('/payment/success');
    final isHttpsFail =
        host.contains('loqma.delivery') && path.contains('/payment/fail');

    if (!isApiCallback && !isHttpsSuccess && !isHttpsFail) return;

    final status = (uri.queryParameters['status'] ?? '').toLowerCase();
    final isSuccess = status == 'success' ||
        status == 'paid' ||
        status == 'completed' ||
        isHttpsSuccess;
    final isFailure = status == 'failed' ||
        status == 'cancelled' ||
        status == 'canceled' ||
        isHttpsFail;

    // API callback without explicit status: wait for webhook / poll — do not close yet.
    if (isApiCallback && !isSuccess && !isFailure) {
      return;
    }

    if (!isSuccess && !isFailure) {
      return;
    }

    _handledCallback = true;
    final result = isSuccess && !isFailure;
    Navigator.of(context).pop<bool>(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hesabPayTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop<bool>(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
