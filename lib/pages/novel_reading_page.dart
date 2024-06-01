import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/image_page.dart';
import 'package:pixes/pages/main_page.dart';
import 'package:pixes/utils/ext.dart';
import 'package:pixes/utils/translation.dart';

class NovelReadingPage extends StatefulWidget {
  const NovelReadingPage(this.novel, {super.key});

  final Novel novel;

  @override
  State<NovelReadingPage> createState() => _NovelReadingPageState();
}

class _NovelReadingPageState extends LoadingState<NovelReadingPage, String> {
  TitleBarAction? action;

  bool isShowingSettings = false;

  @override
  void initState() {
    action = TitleBarAction(MdIcons.tune, "Settings".tl, () {
      if (!isShowingSettings) {
        _NovelReadingSettings.show(context, () {
          setState(() {});
        }).then((value) {
          isShowingSettings = false;
        });
        isShowingSettings = true;
      } else {
        Navigator.of(context).pop();
      }
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      StateController.find<TitleBarController>().addAction(action!);
    });
    super.initState();
  }

  @override
  void dispose() {
    Future.delayed(const Duration(milliseconds: 200), () {
      StateController.find<TitleBarController>().removeAction(action!);
    });
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, String data) {
    var content = buildList(context).toList();
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SelectionArea(
          child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 16.0, height: 1.6),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            return content[index];
          },
          itemCount: content.length,
        ),
      )),
    );
  }

  @override
  Future<Res<String>> loadData() {
    return Network().getNovelContent(widget.novel.id.toString());
  }

  Iterable<Widget> buildList(BuildContext context) sync* {
    double fontSizeAdd = appdata.settings["readingFontSize"] - 16.0;
    double fontHeight = appdata.settings["readingLineHeight"];

    yield Text(widget.novel.title,
        style: TextStyle(
            fontSize: 24.0 + fontSizeAdd, fontWeight: FontWeight.bold));
    yield const SizedBox(height: 12.0);
    yield const Divider(
      style: DividerThemeData(horizontalMargin: EdgeInsets.all(0)),
    );
    yield const SizedBox(height: 12.0);

    var novelContent = data!.split('\n');
    for (var content in novelContent) {
      if (content.isEmpty) continue;
      if (content.startsWith('[uploadedimage:')) {
        var imageId = content.nums;
        yield GestureDetector(
          onTap: () {
            ImagePage.show(["novel:${widget.novel.id.toString()}/$imageId"]);
          },
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: AnimatedImage(
              image:
                  CachedNovelImageProvider(widget.novel.id.toString(), imageId),
              filterQuality: FilterQuality.medium,
              fit: BoxFit.contain,
              height: 300,
              width: double.infinity,
            ),
          ),
        );
      } else if (content.startsWith('[chapter:')) {
        var title = content.replaceLast(']', '').split(':')[1];
        yield Text(title,
                style: TextStyle(
                    fontSize: 20.0 + fontSizeAdd,
                    fontWeight: FontWeight.bold,
                    height: fontHeight))
            .paddingBottom(8);
      } else {
        yield Text(content,
                style:
                    TextStyle(fontSize: 16.0 + fontSizeAdd, height: fontHeight))
            .paddingBottom(appdata.settings["readingParagraphSpacing"]);
      }
    }
  }
}

class _NovelReadingSettings extends StatefulWidget {
  const _NovelReadingSettings(this.callback);

  final void Function() callback;

  static Future show(BuildContext context, void Function() callback) {
    return Navigator.of(context)
        .push(SideBarRoute(_NovelReadingSettings(callback)));
  }

  @override
  State<_NovelReadingSettings> createState() => __NovelReadingSettingsState();
}

class __NovelReadingSettingsState extends State<_NovelReadingSettings> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TitleBar(title: "Reading Settings".tl),
          const SizedBox(height: 8),
          Card(
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text("Font Size".tl),
              subtitle: Slider(
                value: appdata.settings["readingFontSize"],
                onChanged: (value) {
                  setState(() {
                    appdata.settings["readingFontSize"] = value;
                  });
                  appdata.writeSettings();
                  widget.callback();
                },
                min: 12.0,
                max: 24.0,
                divisions: 12,
                label: appdata.settings["readingFontSize"].toString(),
              ),
              trailing: Text(appdata.settings["readingFontSize"].toString()),
            ),
          ).paddingHorizontal(8).paddingBottom(8),
          Card(
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text("Line Height".tl),
              subtitle: Slider(
                value: appdata.settings["readingLineHeight"],
                onChanged: (value) {
                  setState(() {
                    appdata.settings["readingLineHeight"] = value;
                  });
                  appdata.writeSettings();
                  widget.callback();
                },
                min: 1.0,
                max: 2.0,
                divisions: 10,
                label: appdata.settings["readingLineHeight"].toString(),
              ),
              trailing: Text(appdata.settings["readingLineHeight"].toString()),
            ),
          ).paddingHorizontal(8).paddingBottom(8),
          Card(
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text("Paragraph Spacing".tl),
              subtitle: Slider(
                value: appdata.settings["readingParagraphSpacing"],
                onChanged: (value) {
                  setState(() {
                    appdata.settings["readingParagraphSpacing"] = value;
                  });
                  appdata.writeSettings();
                  widget.callback();
                },
                min: 0.0,
                max: 16.0,
                divisions: 8,
                label: appdata.settings["readingParagraphSpacing"].toString(),
              ),
              trailing:
                  Text(appdata.settings["readingParagraphSpacing"].toString()),
            ),
          ).paddingHorizontal(8).paddingBottom(8),
          // 深色模式
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text("Theme".tl),
              trailing: DropDownButton(
                  title: Text(appdata.settings["theme"] ?? "System".tl),
                  items: [
                    MenuFlyoutItem(
                        text: Text("System".tl),
                        onPressed: () {
                          setState(() {
                            appdata.settings["theme"] = "System";
                          });
                          appdata.writeData();
                          StateController.findOrNull(tag: "MyApp")?.update();
                        }),
                    MenuFlyoutItem(
                        text: Text("light".tl),
                        onPressed: () {
                          setState(() {
                            appdata.settings["theme"] = "Light";
                          });
                          appdata.writeData();
                          StateController.findOrNull(tag: "MyApp")?.update();
                        }),
                    MenuFlyoutItem(
                        text: Text("dark".tl),
                        onPressed: () {
                          setState(() {
                            appdata.settings["theme"] = "Dark";
                          });
                          appdata.writeData();
                          StateController.findOrNull(tag: "MyApp")?.update();
                        }),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
