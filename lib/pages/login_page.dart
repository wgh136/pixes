import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/button.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/webview_page.dart';
import 'package:pixes/utils/app_links.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(this.callback, {super.key});

  final void Function() callback;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool checked = false;

  bool waitingForAuth = false;

  bool isLogging = false;

  @override
  Widget build(BuildContext context) {
    if(isLogging) {
      return buildLoading(context);
    } else if (!waitingForAuth) {
      return buildLogin(context);
    } else {
      return buildWaiting(context);
    }
  }

  Widget buildLogin(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login".tl,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FluentButton(
                            onPressed: onContinue,
                            enabled: checked, 
                            width: 96,
                            child: Text("Continue".tl),
                            ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                                "You need to complete the login operation in the browser window that will open."
                                    .tl),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                          checked: checked,
                          onChanged: (value) => setState(() {
                                checked = value ?? false;
                              })),
                      const SizedBox(
                        width: 8,
                      ),
                      Text("I have read and agree to the Terms of Use".tl)
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget buildWaiting(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Waiting...".tl,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                            "Waiting for authentication. Please finished in the browser."
                                .tl),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Button(
                          child: Text("Back".tl),
                          onPressed: () {
                            setState(() {
                              waitingForAuth = false;
                            });
                          }),
                      const Spacer(),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget buildLoading(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Logging in".tl,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: ProgressRing(),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void onContinue() async {
    var url = await Network().generateWebviewUrl();
    onLink = (uri) {
      if (uri.scheme == "pixiv") {
        onFinished(uri.queryParameters["code"]!);
        onLink = null;
        return true;
      }
      return false;
    };
    setState(() {
      waitingForAuth = true;
    });
    if(App.isMobile && mounted) {
      context.to(() => WebviewPage(url, onNavigation: (req) {
        if(req.url.startsWith("pixiv://")) {
          App.rootNavigatorKey.currentState!.pop();
          onLink?.call(Uri.parse(req.url));
          return false;
        }
        return true;
      },));
    } else {
      launchUrlString(url);
    }
  }

  void onFinished(String code) async {
    setState(() {
      isLogging = true;
      waitingForAuth = false;
    });
    var res = await Network().loginWithCode(code);
    if (res.error) {
      if(mounted) {
        context.showToast(message: res.errorMessage!);
      }
      setState(() {
        isLogging = false;
      });
    } else {
      widget.callback();
    }
  }
}
