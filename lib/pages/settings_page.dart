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
            title: "Download Path".tl,
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
            title: "Subpath".tl,
            subtitle: appdata.settings["downloadSubPath"],
            action: Button(
                child: Text("Manage".tl).fixWidth(64),
                onPressed: () {
                  context.to(() => const _SetDownloadSubPathPage());
                }),
          ),
          buildItem(
            title: "Max parallels".tl,
            action: SizedBox(
              width: 64,
              height: 32,
              child: NumberBox<int>(
                value: appdata.settings["maxParallels"],
                autofocus: false,
                onChanged: (value) {
                  appdata.settings["maxParallels"] = value;
                  appdata.writeSettings();
                },
                clearButton: false,
                mode: SpinButtonPlacementMode.none,
              ),
            ),
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
  const _SetDownloadSubPathPage();

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
          TitleBar(title: "Download subpath".tl),
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
                setState(() {
                  appdata.settings["useTranslatedNameForDownload"] = value;
                });
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
                appdata.settings["tagsWeight"] = controller2.text;
                appdata.writeData();
                context.pop();
              } else {
                showToast(context, message: "Invalid".tl);
              }
            },
          ).toAlign(Alignment.centerRight).paddingRight(16),
          const SizedBox(
            height: 16,
          ),
          SelectableText(_instruction).paddingHorizontal(16)
        ],
      ),
    );
  }

  bool check(String text) {
    if (text.startsWith('/') || text.startsWith('\\')) {
      return true;
    }
    return false;
  }

  String get _instruction => """
${"Edit the rule for where to save an image.".tl}
${"Note: The rule should include the filename.".tl}

${"Some keywords will be replaced by the following rule:".tl}
  \${title} -> ${"Title of the work".tl}
  \${author} -> ${"Name of the author".tl}
  \${id} -> ${"Artwork ID".tl}
  \${index} -> ${"Index of the image in the artwork".tl}
  \${ext} -> ${"File extension".tl}

${"Tags: Tags will be sorted by the \"Weights of tags\" setting and replaced by the following rule:".tl}
${"The final text will be affected by the \"Use translated tag name\" setting.".tl}
  \${tag0} -> ${"The first tag of the artwork".tl}
  \${tag1} -> ${"The second tag of the artwork".tl}
  ...

${"Weights of the tags".tl}:
${"Filled with tags. The tags should be separated by a space. The tag in front has higher weight.".tl}
${"It is required to use the original name instead of the translated name.".tl}
""";
}
