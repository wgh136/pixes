import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/cache_manager.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/pages/main_page.dart';
import 'package:pixes/utils/io.dart';
import 'package:pixes/utils/translation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:window_manager/window_manager.dart';

class ImagePage extends StatefulWidget {
  const ImagePage(this.url, {super.key});

  final String url;

  static show(String url) {
    App.rootNavigatorKey.currentState
        ?.push(AppPageRoute(builder: (context) => ImagePage(url)));
  }

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with WindowListener {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
              child: PhotoView(
            backgroundDecoration: BoxDecoration(
                color: FluentTheme.of(context).micaBackgroundColor),
            filterQuality: FilterQuality.medium,
            imageProvider: widget.url.startsWith("file://")
                ? FileImage(File(widget.url.replaceFirst("file://", "")))
                : CachedImageProvider(widget.url) as ImageProvider,
          )),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  const SizedBox(
                    width: 6,
                  ),
                  IconButton(
                      icon: const Icon(FluentIcons.back).paddingAll(2),
                      onPressed: () => context.pop()),
                  const Expanded(
                    child: DragToMoveArea(
                      child: SizedBox.expand(),
                    ),
                  ),
                  buildActions(),
                  if (App.isDesktop)
                    WindowButtons(
                      key: ValueKey(windowButtonKey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  var menuController = FlyoutController();

  Future<File?> getFile() async{
    if (widget.url.startsWith("file://")) {
      return File(widget.url.replaceFirst("file://", ""));
    }
    var res = await CacheManager().findCache(widget.url);
    if(res == null){
      return null;
    }
    return File(res);
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
            var fileName = file.path.split('/').last;
            String ext;
            if(!fileName.contains('.')){
              ext = 'jpg';
              fileName += '.jpg';
            } else {
              ext = file.path.split('.').last;
            }
            var mediaType = switch(ext){
              'jpg' => 'image/jpeg',
              'jpeg' => 'image/jpeg',
              'png' => 'image/png',
              'gif' => 'image/gif',
              'webp' => 'image/webp',
              _ => 'application/octet-stream'
            };
            Share.shareXFiles([XFile.fromData(
              await file.readAsBytes(),
              mimeType: mediaType,
              name: fileName)]
            );
          }
        }),
      ],
    ));
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
