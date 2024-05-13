import 'package:fluent_ui/fluent_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/pages/main_page.dart';
import 'package:window_manager/window_manager.dart';

class ImagePage extends StatefulWidget {
  const ImagePage(this.url, {super.key});

  final String url;

  static show(String url) {
    App.rootNavigatorKey.currentState?.push(
        AppPageRoute(builder: (context) => ImagePage(url)));
  }

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with WindowListener{
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
    return ColoredBox(
      color: FluentTheme.of(context).micaBackgroundColor.withOpacity(1),
      child: Stack(
        children: [
          Positioned.fill(child: PhotoView(
            backgroundDecoration: const BoxDecoration(
                color: Colors.transparent
            ),
            filterQuality: FilterQuality.medium,
            imageProvider: CachedImageProvider(widget.url),
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
                  WindowButtons(key: ValueKey(windowButtonKey),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
