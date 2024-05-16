import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pixes/components/grid.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/message.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/download.dart';
import 'package:pixes/pages/illust_page.dart';
import 'package:pixes/utils/translation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/io.dart';
import 'main_page.dart';

class DownloadedPage extends StatefulWidget {
  const DownloadedPage({super.key});

  @override
  State<DownloadedPage> createState() => _DownloadedPageState();
}

class _DownloadedPageState extends State<DownloadedPage> {
  var illusts = <DownloadedIllust>[];
  var flyoutControllers = <FlyoutController>[];

  void loadData() {
    illusts = DownloadManager().listAll();
    flyoutControllers = List.generate(illusts.length, (index) => FlyoutController());
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(title: "Downloaded".tl),
        Expanded(
          child: buildBody(),
        ),
      ],
    );
  }

  Widget buildBody() {
    return GridViewWithFixedItemHeight(
      itemCount: illusts.length,
      itemHeight: 152,
      maxCrossAxisExtent: 742,
      builder: (context, index) {
        var image = DownloadManager().getImage(illusts[index].illustId, 0);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 96,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: ColorScheme.of(context).secondaryContainer
                ),
                clipBehavior: Clip.antiAlias,
                child: image == null ? null : Image(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      illusts[index].title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      illusts[index].author,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${illusts[index].imageCount}P",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        Button(
                          child: Text("View".tl).fixWidth(42),
                          onPressed: () {
                            var images = DownloadManager().getImagePaths(
                                illusts[index].illustId);
                            if(images.isEmpty) {
                              showToast(context, message: "No images found".tl);
                              return;
                            }
                            App.rootNavigatorKey.currentState?.push(
                                AppPageRoute(builder: (context) {
                                  return _DownloadedIllustViewPage(images);
                                }));
                          },
                        ),
                        const SizedBox(width: 6),
                        Button(
                          child: Text("Info".tl).fixWidth(42),
                          onPressed: () {
                            context.to(() => IllustPageWithId(
                                illusts[index].illustId.toString()));
                          },
                        ),
                        const SizedBox(width: 6),
                        FlyoutTarget(
                          controller: flyoutControllers[index],
                          child: Button(
                            child: Text("Delete".tl).fixWidth(42),
                            onPressed: () {
                              flyoutControllers[index].showFlyout(
                                navigatorKey: App.rootNavigatorKey.currentState,
                                builder: (context) {
                                  return FlyoutContent(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Are you sure you want to delete?'.tl,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Button(
                                          onPressed: () {
                                            Flyout.of(context).close();
                                            DownloadManager().delete(illusts[index]);
                                            setState(() {
                                              illusts.removeAt(index);
                                              flyoutControllers.removeAt(index);
                                            });
                                          },
                                          child: Text('Yes'.tl),
                                        ),
                                      ],
                                    ),
                                  );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    ).paddingHorizontal(8);
  }
}

class _DownloadedIllustViewPage extends StatefulWidget {
  const _DownloadedIllustViewPage(this.imagePaths);

  final List<String> imagePaths;

  @override
  State<_DownloadedIllustViewPage> createState() => _DownloadedIllustViewPageState();
}

class _DownloadedIllustViewPageState extends State<_DownloadedIllustViewPage> with WindowListener{
  int windowButtonKey = 0;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      windowButtonKey++;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      windowButtonKey++;
    });
  }

  var controller = PageController();

  int currentPage = 0;

  var menuController = FlyoutController();

  Future<File?> getFile() async {
    var file = File(widget.imagePaths[currentPage]);
    if(file.existsSync()) {
      return file;
    }
    return null;
  }

  void showMenu() {
    menuController.showFlyout(builder: (context) => MenuFlyout(
      items: [
        MenuFlyoutItem(text: Text("Save to".tl), onPressed: () async{
          var file = await getFile();
          if(file != null){
            saveFile(file);
          }
        }),
        MenuFlyoutItem(text: Text("Share".tl), onPressed: () async{
          var file = await getFile();
          if(file != null){
            var ext = file.path.split('.').last;
            var mediaType = switch(ext){
              'jpg' => 'image/jpeg',
              'jpeg' => 'image/jpeg',
              'png' => 'image/png',
              'gif' => 'image/gif',
              'webp' => 'image/webp',
              _ => 'application/octet-stream'
            };
            Share.shareXFiles([XFile(file.path, mimeType: mediaType, name: file.path.split('/').last)]);
          }
        }),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Listener(
        onPointerSignal: (event) {
          if(event is PointerScrollEvent &&
              !HardwareKeyboard.instance.isControlPressed) {
            if(event.scrollDelta.dy > 0
                && controller.page!.toInt() < widget.imagePaths.length - 1) {
              controller.jumpToPage(controller.page!.toInt() + 1);
            } else if(event.scrollDelta.dy < 0 && controller.page!.toInt() > 0){
              controller.jumpToPage(controller.page!.toInt() - 1);
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constrains) {
            var height = constrains.maxHeight;
            return Stack(
              children: [
                Positioned.fill(child: PhotoViewGallery.builder(
                  pageController: controller,
                  backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent
                  ),
                  itemCount: widget.imagePaths.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(File(widget.imagePaths[index])),
                    );
                  },
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                )),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        const SizedBox(width: 6,),
                        IconButton(
                            icon: const Icon(FluentIcons.back).paddingAll(2),
                            onPressed: () => context.pop()
                        ),
                        const Expanded(
                          child: DragToMoveArea(child: SizedBox.expand(),),
                        ),
                        buildActions(),
                        if(App.isDesktop)
                          WindowButtons(key: ValueKey(windowButtonKey),),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: height / 2 - 9,
                  child: IconButton(
                    icon: const Icon(FluentIcons.chevron_left, size: 18,),
                    onPressed: () {
                      controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ).paddingAll(8),
                ),
                Positioned(
                  right: 0,
                  top: height / 2 - 9,
                  child: IconButton(
                    icon: const Icon(FluentIcons.chevron_right, size: 18),
                    onPressed: () {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ).paddingAll(8),
                ),
                Positioned(
                  left: 12,
                  bottom: 8,
                  child: Text(
                    "${currentPage + 1}/${widget.imagePaths.length}",
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildActions() {
    var width = MediaQuery.of(context).size.width;
    return FlyoutTarget(
      controller: menuController,
      child: width > 600
          ? Button(
          onPressed: showMenu,
          child: const Row(
            children: [
              Icon(
                MdIcons.menu,
                size: 18,
              ),
              SizedBox(
                width: 8,
              ),
              Text('Actions'),
            ],
          ))
          : IconButton(
          icon: const Icon(
            MdIcons.more_horiz,
            size: 20,
          ),
          onPressed: showMenu),
    );
  }
}

