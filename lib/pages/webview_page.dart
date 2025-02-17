import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/md.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../foundation/app.dart';

double get _appBarHeight => App.isDesktop ? 36.0 : 48.0;

class WebviewPage extends StatefulWidget {
  const WebviewPage(this.url, {this.onNavigation, super.key});

  final String url;

  final bool Function(NavigationRequest req)? onNavigation;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  NavigationDecision handleNavigation(NavigationRequest req) {
    if (widget.onNavigation != null) {
      return widget.onNavigation!(req)
          ? NavigationDecision.navigate
          : NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    controller ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          FluentTheme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    return Column(
      children: [
        SizedBox(
          height: _appBarHeight,
          child: Row(
            children: [
              const Text("Webview"),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  MdIcons.open_in_new,
                  size: 20,
                ),
                onPressed: () {
                  launchUrlString(widget.url);
                  context.pop();
                },
              ),
            ],
          ).paddingHorizontal(16),
        ).paddingTop(MediaQuery.of(context).padding.top),
        Expanded(
          child: WebViewWidget(
            controller: controller!,
          ),
        ),
      ],
    );
  }
}
