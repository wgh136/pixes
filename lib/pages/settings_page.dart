import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/pages/main_page.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: CustomScrollView(
        slivers: [
          SliverTitleBar(title: "Settings".tl),
          buildHeader("Account".tl),
          buildAccount(),
          SliverPadding(padding: EdgeInsets.only(bottom: context.padding.bottom)),
        ],
      ),
    );
  }

  Widget buildHeader(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),);
  }

  Widget buildItem({required String title, String? subtitle, Widget? action}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: action,
      ),
    );
  }
  
  Widget buildAccount(){
    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildItem(
            title: "Logout".tl,
            action: Button(
              onPressed: () {
                showDialog<String>(
                  context: App.rootNavigatorKey.currentContext!,
                  builder: (context) => ContentDialog(
                    title: Text('Logout'.tl),
                    content: Text('Are you sure you want to logout?'.tl),
                    actions: [
                      Button(
                        child: Text('Continue'.tl),
                        onPressed: () {
                          appdata.account = null;
                          App.rootNavigatorKey.currentState!.pushAndRemoveUntil(
                              AppPageRoute(
                                  builder: (context) => const MainPage()),
                                  (route) => false
                          );
                        },
                      ),
                      FilledButton(
                        child: Text('Cancel'.tl),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Continue".tl).fixWidth(64),
            ),
          ),
          buildItem(title: "Account Settings".tl, action: Button(
            child: Text("Edit".tl).fixWidth(64),
            onPressed: (){
              launchUrlString("https://www.pixiv.net/setting_user.php");
            },
          )),
        ],
      ),
    );
  }
}