import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/features/webview/models/habit_webview_entity.dart';

class HabitWebviewController extends GetxController {
  final title = ''.obs;
  final url = ''.obs;
  final assetPath = ''.obs;
  final isLoading = true.obs;

  InAppWebViewController? webViewController;

  /// Prefer local asset over remote URL when both are set.
  String? get initialFile {
    final path = assetPath.value;
    return path.isNotEmpty ? path : null;
  }

  URLRequest? get initialUrlRequest {
    if (initialFile != null) return null;
    final remote = url.value;
    if (remote.isEmpty) return null;
    return URLRequest(url: WebUri(remote));
  }

  InAppWebViewSettings get settings => InAppWebViewSettings(
        javaScriptEnabled: false,
        transparentBackground: true,
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,
        disableHorizontalScroll: false,
        disableVerticalScroll: false,
      );

  @override
  void onInit() {
    super.onInit();
    _applyArgs(Get.arguments);
  }

  void _applyArgs(dynamic raw) {
    if (raw is! WebviewEntity) return;
    title.value = raw.title ?? '';
    assetPath.value = raw.assets ?? '';
    url.value = raw.url ?? '';
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
  }

  void onLoadStart(InAppWebViewController controller, WebUri? uri) {
    isLoading.value = true;
  }

  void onLoadStop(InAppWebViewController controller, WebUri? uri) {
    isLoading.value = false;
  }

  void onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    isLoading.value = false;
  }
}
