import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Chrome mobile UA — CDN allows browser-like clients after the JS check.
const String cdnWebViewUserAgent =
    'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

/// Off-screen WebView used to pass CDN JavaScript browser checks.
class CdnWarmupHost extends StatefulWidget {
  const CdnWarmupHost({super.key});

  static CdnWarmupHostController? controller;
  static final Completer<void> ready = Completer<void>();

  @override
  State<CdnWarmupHost> createState() => _CdnWarmupHostState();
}

/// Loads API URLs through the hidden CDN WebView.
class CdnWarmupHostController {
  CdnWarmupHostController(this._state);

  final _CdnWarmupHostState _state;

  Future<dynamic> fetchJson(
    Uri url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 45),
  }) =>
      _state.fetchJson(url, headers: headers, timeout: timeout);

  Future<dynamic> fetchApi(
    Uri url, {
    String method = 'GET',
    String? body,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 45),
  }) =>
      _state.fetchApi(
        url,
        method: method,
        body: body,
        headers: headers,
        timeout: timeout,
      );
}

class _CdnWarmupHostState extends State<CdnWarmupHost> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      if (!CdnWarmupHost.ready.isCompleted) CdnWarmupHost.ready.complete();
      return;
    }
    CdnWarmupHost.controller = CdnWarmupHostController(this);
    _initController();
  }

  @override
  void dispose() {
    if (CdnWarmupHost.controller?._state == this) {
      CdnWarmupHost.controller = null;
    }
    super.dispose();
  }

  Future<void> _initController() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setUserAgent(cdnWebViewUserAgent)
      ..addJavaScriptChannel(
        'LoqmaCdnBridge',
        onMessageReceived: _onBridgeMessage,
      );

    _controller = controller;
    if (mounted) setState(() {});
    if (!CdnWarmupHost.ready.isCompleted) {
      CdnWarmupHost.ready.complete();
    }
  }

  Completer<dynamic>? _activeFetch;
  Timer? _activeTimer;

  void _onBridgeMessage(JavaScriptMessage message) {
    final fetch = _activeFetch;
    if (fetch == null || fetch.isCompleted) return;
    _activeTimer?.cancel();
    try {
      fetch.complete(jsonDecode(message.message));
    } catch (error) {
      fetch.completeError(
        FormatException('CDN WebView returned invalid JSON: $error'),
      );
    }
  }

  Future<void> _ensureController() async {
    if (_controller != null) return;
    await CdnWarmupHost.ready.future;
    for (var i = 0; i < 30; i++) {
      if (_controller != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('CDN WebView is not ready');
  }

  /// Loads [url] in the WebView and returns JSON after the CDN security page.
  Future<dynamic> fetchJson(
    Uri url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 45),
  }) =>
      fetchApi(url, headers: headers, timeout: timeout);

  /// Runs fetch/XHR inside the WebView (GET/POST/PUT/PATCH/DELETE) after CDN warmup.
  Future<dynamic> fetchApi(
    Uri url, {
    String method = 'GET',
    String? body,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await _ensureController();
    final controller = _controller!;
    final upperMethod = method.toUpperCase();

    _activeTimer?.cancel();
    _activeFetch?.completeError(StateError('CDN fetch superseded'));
    final completer = Completer<dynamic>();
    _activeFetch = completer;

    var finished = false;
    void finish(Object? result, {Object? error}) {
      if (finished) return;
      finished = true;
      _activeTimer?.cancel();
      if (_activeFetch == completer) _activeFetch = null;
      if (error != null) {
        if (!completer.isCompleted) completer.completeError(error);
      } else {
        if (!completer.isCompleted) completer.complete(result);
      }
    }

    Future<void> pollBody() async {
      for (var i = 0; i < 120; i++) {
        if (finished) return;
        await Future<void>.delayed(const Duration(milliseconds: 500));
        try {
          final json = await _readJsonBody(controller);
          if (json != null) {
            finish(json);
            return;
          }
        } catch (_) {}
      }
    }

    Future<void> runJsFetch() async {
      if (finished) return;
      final safeUrl = url.toString().replaceAll(r'\', r'\\').replaceAll("'", r"\'");
      final safeMethod = upperMethod.replaceAll("'", r"\'");
      final safeBody = (body ?? '').replaceAll(r'\', r'\\').replaceAll("'", r"\'");
      final headerEntries = headers.entries
          .map((e) => "'${_escapeJs(e.key)}':'${_escapeJs(e.value)}'")
          .join(',');
      final bodySnippet = safeBody.isEmpty
          ? 'undefined'
          : "'$safeBody'";
      await controller.runJavaScript('''
(function(){
  if(window.__loqmaCdnFetchStarted)return;
  window.__loqmaCdnFetchStarted=true;
  var opts={method:'$safeMethod',credentials:'include',headers:{$headerEntries}};
  if($bodySnippet!==undefined){opts.body=$bodySnippet;}
  fetch('$safeUrl',opts)
    .then(function(r){return r.text();})
    .then(function(t){LoqmaCdnBridge.postMessage(t);})
    .catch(function(e){LoqmaCdnBridge.postMessage(JSON.stringify({error:String(e)}));});
})();
      ''');
    }

    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          unawaited(pollBody());
          unawaited(Future<void>.delayed(
            const Duration(seconds: 6),
            runJsFetch,
          ));
        },
      ),
    );

    _activeTimer = Timer(timeout, () {
      finish(null, error: TimeoutException('CDN security check timed out'));
    });

    final loadHeaders = <String, String>{
      'Accept': 'application/json',
      ...headers,
    };

    try {
      await controller.runJavaScript('window.__loqmaCdnFetchStarted=false;');
      if (upperMethod == 'GET') {
        await controller.loadRequest(url, headers: loadHeaders);
      } else {
        await controller.loadRequest(
          Uri.parse('${url.origin}/'),
          headers: loadHeaders,
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        await runJsFetch();
      }
    } catch (error) {
      finish(null, error: error);
    }

    unawaited(pollBody());
    if (upperMethod == 'GET') {
      unawaited(Future<void>.delayed(const Duration(seconds: 6), runJsFetch));
    }

    return completer.future;
  }

  Future<dynamic> _readJsonBody(WebViewController controller) async {
    final raw = await controller.runJavaScriptReturningResult(
      '(function(){'
      'var t=(document.body&&document.body.innerText||"").trim();'
      'if(!t||t.charAt(0)!=="{" )return "";'
      'if(t.toLowerCase().indexOf("checking your browser")>=0)return "";'
      'return t;'
      '})()',
    );
    final text = _jsString(raw);
    if (text.isEmpty) return null;
    return jsonDecode(text);
  }

  String _jsString(Object? value) {
    if (value == null) return '';
    var s = value.toString();
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      s = s.substring(1, s.length - 1);
      s = s.replaceAll(r'\n', '\n').replaceAll(r'\"', '"').replaceAll(r'\\', '\\');
    }
    return s.trim();
  }

  String _escapeJs(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _controller == null) {
      return const SizedBox.shrink();
    }
    // Must have real dimensions — 1x1/offstage WebViews skip JS on many devices.
    return Positioned(
      left: -10000,
      top: 0,
      width: 360,
      height: 640,
      child: IgnorePointer(
        child: WebViewWidget(controller: _controller!),
      ),
    );
  }
}
