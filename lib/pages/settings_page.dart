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

import 'logs.dart';

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
          buildHeader("Browse".tl),
          buildBrowse(),
          buildHeader("Download".tl),
          buildDownload(),
          buildHeader("Appearance".tl),
          buildAppearance(),
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
                    showToast(context, message: "Unsupported platform".tl);
                    return;
                  }
                  context.to(() => _SetSingleFieldPage(
                    "Download Path".tl,
                    "downloadPath",
                    check: (text) {
                      if(!Directory(text).havePermission()) {
                        return "No permission".tl;
                      } else {
                        return null;
                      }
                    },
                  ));
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
          buildItem(
              title: "Logs",
              action: IconButton(
                icon: const Icon(MdIcons.open_in_new, size: 18,),
                onPressed: () => context.to(() => const LogsPage())
              )),
        ],
      ),
    );
  }

  Widget buildBrowse() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildItem(
              title: "Proxy".tl,
              action: Button(
                child: Text("Edit".tl).fixWidth(64),
                onPressed: () {
                  context.to(() => _SetSingleFieldPage(
                    "Http ${"Proxy".tl}",
                    "proxy",
                  ));
                },
              )),
        ],
      ),
    );
  }

  Widget buildAppearance() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildItem(
              title: "Theme".tl,
              action: DropDownButton(
                title: Text(appdata.settings["theme"] ?? "System".tl),
                items: [
                  MenuFlyoutItem(text: Text("System".tl), onPressed: () {
                    setState(() {
                      appdata.settings["theme"] = "System";
                    });
                    appdata.writeData();
                    StateController.findOrNull(tag: "MyApp")?.update();
                  }),
                  MenuFlyoutItem(text: Text("light".tl), onPressed: () {
                    setState(() {
                      appdata.settings["theme"] = "Light";
                    });
                    appdata.writeData();
                    StateController.findOrNull(tag: "MyApp")?.update();
                  }),
                  MenuFlyoutItem(text: Text("dark".tl), onPressed: () {
                    setState(() {
                      appdata.settings["theme"] = "Dark";
                    });
                    appdata.writeData();
                    StateController.findOrNull(tag: "MyApp")?.update();
                  }),
              ])),
          buildItem(
              title: "Language".tl,
              action: DropDownButton(
                  title: Text(appdata.settings["language"] ?? "System"),
                  items: [
                    MenuFlyoutItem(text: const Text("System"), onPressed: () {
                      setState(() {
                        appdata.settings["language"] = "System";
                      });
                      appdata.writeData();
                      StateController.findOrNull(tag: "MyApp")?.update();
                    }),
                    MenuFlyoutItem(text: const Text("English"), onPressed: () {
                      setState(() {
                        appdata.settings["language"] = "English";
                      });
                      appdata.writeData();
                      StateController.findOrNull(tag: "MyApp")?.update();
                    }),
                    MenuFlyoutItem(text: const Text("简体中文"), onPressed: () {
                      setState(() {
                        appdata.settings["language"] = "简体中文";
                      });
                      appdata.writeData();
                      StateController.findOrNull(tag: "MyApp")?.update();
                    }),
                    MenuFlyoutItem(text: const Text("繁體中文"), onPressed: () {
                      setState(() {
                        appdata.settings["language"] = "繁體中文";
                      });
                      appdata.writeData();
                      StateController.findOrNull(tag: "MyApp")?.update();
                    }),
                  ])),
        ],
      ),
    );
  }
}

class _SetSingleFieldPage extends StatefulWidget {
  const _SetSingleFieldPage(this.title, this.field, {this.check});

  final String title;

  final String field;

  final String? Function(String)? check;

  @override
  State<_SetSingleFieldPage> createState() => _SetSingleFieldPageState();
}

class _SetSingleFieldPageState extends State<_SetSingleFieldPage> {
  late final controller =
      TextEditingController(text: appdata.settings[widget.field]);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleBar(title: widget.title),
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
            var checkRes = widget.check?.call(text);
            if (checkRes == null) {
              appdata.settings[widget.field] = text;
              appdata.writeData();
              context.pop();
            } else {
              showToast(context, message: checkRes);
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
  \${page} -> ${"Replace with '-p\${index}' if the work have more than one images, otherwise replace with blank.".tl}
  \${ext} -> ${"File extension".tl}
  \${AI} -> ${"Replace with 'AI' if the work was generated by AI, otherwise replace with blank".tl}
  \${tag(*)} -> ${"Replace with * if the work have tag *, otherwise replace with blank.".tl}

${"Multiple path separators will be automatically replaced with a single".tl}
""";
}
