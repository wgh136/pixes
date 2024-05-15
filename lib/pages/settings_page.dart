import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/message.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/pages/main_page.dart';
import 'package:pixes/utils/io.dart';
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
          buildHeader("Download".tl),
          buildDownload(),
          buildHeader("About".tl),
          buildAbout(),
          SliverPadding(
              padding: EdgeInsets.only(bottom: context.padding.bottom)),
        ],
      ),
    );
  }

  Widget buildHeader(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
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

  Widget buildAccount() {
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
                              (route) => false);
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
          buildItem(
              title: "Account Settings".tl,
              action: Button(
                child: Text("Edit".tl).fixWidth(64),
                onPressed: () {
                  launchUrlString("https://www.pixiv.net/setting_user.php");
                },
              )),
        ],
      ),
    );
  }

  Widget buildDownload() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildItem(
            title: "Download Path",
            subtitle: appdata.settings["downloadPath"],
            action: Button(
                child: Text("Manage".tl).fixWidth(64),
                onPressed: () {
                  if (Platform.isIOS) {
                    showToast(context, message: "Unsupport platform".tl);
                    return;
                  }
                  context.to(() => const _SetDownloadPathPage());
                }),
          ),
          buildItem(
            title: "Subpath",
            subtitle: appdata.settings["downloadSubPath"],
            action: Button(
                child: Text("Manage".tl).fixWidth(64),
                onPressed: () {
                  context.to(() => const _SetDownloadSubPathPage());
                }),
          ),
        ],
      ),
    );
  }

  Widget buildAbout() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildItem(title: "Version", subtitle: App.version),
          buildItem(
              title: "Github",
              action: IconButton(
                icon: const Icon(MdIcons.open_in_new, size: 18,),
                onPressed: () =>
                    launchUrlString("https://github.com/wgh136/pixes"),
              )),
          buildItem(
              title: "Telegram",
              action: IconButton(
                icon: const Icon(MdIcons.open_in_new, size: 18,),
                onPressed: () =>
                    launchUrlString("https://t.me/pica_group"),
              )),
        ],
      ),
    );
  }
}

class _SetDownloadPathPage extends StatefulWidget {
  const _SetDownloadPathPage();

  @override
  State<_SetDownloadPathPage> createState() => __SetDownloadPathPageState();
}

class __SetDownloadPathPageState extends State<_SetDownloadPathPage> {
  final controller =
      TextEditingController(text: appdata.settings["downloadPath"]);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(title: "Download Path".tl),
        TextBox(
          controller: controller,
        ).paddingHorizontal(16),
        const SizedBox(
          height: 8,
        ),
        Button(
          child: Text("Confirm".tl),
          onPressed: () {
            var text = controller.text;
            if (Directory(text).havePermission()) {
              appdata.settings["downloadPath"] = text;
              appdata.writeData();
              context.pop();
            } else {
              showToast(context, message: "No Permission".tl);
            }
          },
        ).toAlign(Alignment.centerRight).paddingRight(16),
      ],
    );
  }
}

class _SetDownloadSubPathPage extends StatefulWidget {
  const _SetDownloadSubPathPage({super.key});

  @override
  State<_SetDownloadSubPathPage> createState() =>
      __SetDownloadSubPathPageState();
}

class __SetDownloadSubPathPageState extends State<_SetDownloadSubPathPage> {
  final controller =
      TextEditingController(text: appdata.settings["downloadSubPath"]);
  final controller2 =
      TextEditingController(text: appdata.settings["tagsWeight"]);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleBar(title: "Download Subpath".tl),
          Text("Rule".tl)
              .padding(const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
          TextBox(
            controller: controller,
          ).paddingHorizontal(16),
          Text("Weights of the tags".tl)
              .padding(const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
          TextBox(
            controller: controller2,
          ).paddingHorizontal(16),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            title: Text("Use translated tag name".tl),
            trailing: ToggleSwitch(
              checked: appdata.settings["useTranslatedNameForDownload"],
              onChanged: (value) {
                appdata.settings["useTranslatedNameForDownload"] = value;
                appdata.writeSettings();
              },
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Button(
            child: Text("Confirm".tl),
            onPressed: () {
              var text = controller.text;
              if (check(text)) {
                appdata.settings["downloadSubPath"] = text;
                appdata.writeData();
                context.pop();
              } else {
                showToast(context, message: "No Permission".tl);
              }
            },
          ).toAlign(Alignment.centerRight).paddingRight(16),
          const SizedBox(
            height: 16,
          ),
          Text(_instruction).paddingHorizontal(16)
        ],
      ),
    );
  }

  bool check(String text) {
    if (!text.startsWith('/') || !text.startsWith('\\')) {
      return false;
    }
    return true;
  }

  String get _instruction => """
${"Edit the rule of where to store a image.".tl}
${"Note: The rule should contain file name.".tl}

${"Some keyword will be replaced as following rule:"}
  \${title} -> ${"Title of the actwork".tl}
  \${author} -> ${"Name of the author".tl}
  \${id} -> ${"Actwork ID".tl}
  \${index} -> ${"Index of the image in the artwork".tl}
  \${ext} -> ${"File extension".tl}
  ${"Tags: Tags will be sorted with \"Weights of tags\" setting and be replaced with following rule".tl}
  ${"The final text will be affect by the setting og \"Use translated tag name\"".tl}
  \${tag0} -> ${"The first tag of the artwork".tl}
  \${tag1} -> ${"The sencondary tag of the artwork".tl}

${"Weights of the tags".tl}:
Filled with tags. The tags should be splited with a space. The tag in the front have higher weight.
It is required to use originlal name instead of translated name.
""";
}
