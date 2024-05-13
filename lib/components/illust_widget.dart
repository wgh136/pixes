import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';

import '../network/network.dart';
import '../pages/illust_page.dart';
import 'md.dart';

class IllustWidget extends StatefulWidget {
  const IllustWidget(this.illust, {super.key});

  final Illust illust;

  @override
  State<IllustWidget> createState() => _IllustWidgetState();
}

class _IllustWidgetState extends State<IllustWidget> {
  bool isBookmarking = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final width = constrains.maxWidth;
      final height = widget.illust.height * width / widget.illust.width;
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: Container(
              width: width,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Card(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: GestureDetector(
                  onTap: (){
                    context.to(() => IllustPage(widget.illust, favoriteCallback: (v) {
                      setState(() {
                        widget.illust.isBookmarked = v;
                      });
                    },));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: AnimatedImage(
                      image: CachedImageProvider(widget.illust.images.first.medium),
                      fit: BoxFit.cover,
                      width: width-16.0,
                      height: height-16.0,
                    ),
                  ),
                ),
              ),
            )),
            Positioned(
              top: 16,
              right: 16,
              child: buildButton(),
            )
          ],
        ),
      );
    });
  }

  Widget buildButton() {
    void favorite() async{
      if(isBookmarking) return;
      setState(() {
        isBookmarking = true;
      });
      var method = widget.illust.isBookmarked ? "delete" : "add";
      var res = await Network().addBookmark(widget.illust.id.toString(), method);
      if(res.error) {
        if(mounted) {
          context.showToast(message: "Network Error");
        }
      } else {
        widget.illust.isBookmarked = !widget.illust.isBookmarked;
      }
      setState(() {
        isBookmarking = false;
      });
    }

    Widget child;
    if(isBookmarking) {
      child = const SizedBox(
        width: 14,
        height: 14,
        child: ProgressRing(strokeWidth: 1.6,),
      );
    } else if(widget.illust.isBookmarked) {
      child = Icon(
        MdIcons.favorite,
        color: ColorScheme.of(context).error,
        size: 22,
      );
    } else {
      child = Icon(
        MdIcons.favorite,
        color: ColorScheme.of(context).outline,
        size: 22,
      );
    }

    return SizedBox(
      height: 24,
      width: 24,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: favorite,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
