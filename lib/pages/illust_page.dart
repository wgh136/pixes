import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/download.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/image_page.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../components/color_scheme.dart';

const _kBottomBarHeight = 64.0;

class IllustPage extends StatefulWidget {
  const IllustPage(this.illust, {super.key});

  final Illust illust;

  @override
  State<IllustPage> createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: SizedBox.expand(
        child: ColoredBox(
          color: FluentTheme.of(context).scaffoldBackgroundColor,
          child: LayoutBuilder(builder: (context, constrains) {
            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: buildBody(constrains.maxWidth, constrains.maxHeight),
                ),
                _BottomBar(widget.illust, constrains.maxHeight, constrains.maxWidth),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildBody(double width, double height) {
    return ListView.builder(
        itemCount: widget.illust.images.length + 2,
        itemBuilder: (context, index) {
          return buildImage(width, height, index);
        });
  }

  Widget buildImage(double width, double height, int index) {
    if (index == 0) {
      return Text(
        widget.illust.title,
        style: const TextStyle(fontSize: 24),
      ).paddingVertical(8).paddingHorizontal(12);
    }
    index--;
    if (index == widget.illust.images.length) {
      return const SizedBox(
        height: _kBottomBarHeight,
      );
    }
    var imageWidth = width;
    var imageHeight = widget.illust.height * width / widget.illust.width;
    if (imageHeight > height) {
      // 确保图片能够完整显示在屏幕上
      var scale = imageHeight / height;
      imageWidth = imageWidth / scale;
      imageHeight = height;
    }
    var image = SizedBox(
      width: imageWidth,
      height: imageHeight,
      child: GestureDetector(
        onTap: () => ImagePage.show(widget.illust.images[index].original),
        child: AnimatedImage(
          image: CachedImageProvider(widget.illust.images[index].medium),
          width: imageWidth,
          fit: BoxFit.cover,
          height: imageHeight,
        ),
      ),
    );

    if (index == 0) {
      return Hero(
        tag: "illust_${widget.illust.id}",
        child: image,
      );
    } else {
      return image;
    }
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar(this.illust, this.height, this.width);

  final Illust illust;

  final double height;

  final double width;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  double? top;

  double pageHeight = 0;

  double widgetHeight = 48;

  final key = GlobalKey();

  double _width = 0;

  @override
  void initState() {
    _width = widget.width;
    pageHeight = widget.height;
    top = pageHeight - _kBottomBarHeight;
    Future.delayed(const Duration(milliseconds: 200), () {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      widgetHeight = (box?.size.height) ?? 0;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _BottomBar oldWidget) {
    if (widget.height != pageHeight) {
      setState(() {
        pageHeight = widget.height;
        top = pageHeight - _kBottomBarHeight;
      });
    }
    if(_width != widget.width) {
      _width = widget.width;
      Future.microtask(() {
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        var oldHeight = widgetHeight;
        widgetHeight = (box?.size.height) ?? 0;
        if(oldHeight != widgetHeight && top != pageHeight - _kBottomBarHeight) {
          setState(() {
            top = pageHeight - widgetHeight;
          });
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      left: 0,
      right: 0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.ease,
      child: Card(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        backgroundColor:
            FluentTheme.of(context).micaBackgroundColor.withOpacity(0.96),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: double.infinity,
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTop(),
              buildStats(),
              buildTags(),
              SelectableText("${"Artwork ID".tl}: ${widget.illust.id}\n${"Artist ID".tl}: ${widget.illust.author.id}", style: TextStyle(color: ColorScheme.of(context).outline),).paddingLeft(4),
              const SizedBox(height: 8,)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTop() {
    return SizedBox(
      height: _kBottomBarHeight,
      width: double.infinity,
      child: LayoutBuilder(builder: (context, constrains) {
        return Row(
          children: [
            buildAuthor(),
            ...buildActions(constrains.maxWidth),
            const Spacer(),
            if (top == pageHeight - _kBottomBarHeight)
              IconButton(
                  icon: const Icon(FluentIcons.up),
                  onPressed: () {
                    setState(() {
                      top = pageHeight - widgetHeight;
                    });
                  })
            else
              IconButton(
                  icon: const Icon(FluentIcons.down),
                  onPressed: () {
                    setState(() {
                      top = pageHeight - _kBottomBarHeight;
                    });
                  })
          ],
        );
      }),
    );
  }

  bool isFollowing = false;

  Widget buildAuthor() {
    void follow() async{
      if(isFollowing) return;
      setState(() {
        isFollowing = true;
      });
      var method = widget.illust.author.isFollowed ? "delete" : "add";
      var res = await Network().follow(widget.illust.author.id.toString(), method);
      if(res.error) {
        if(mounted) {
          context.showToast(message: "Network Error");
        }
      } else {
        widget.illust.author.isFollowed = !widget.illust.author.isFollowed;
      }
      setState(() {
        isFollowing = false;
      });
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: FluentTheme.of(context).cardColor.withOpacity(0.72),
      child: SizedBox(
        height: double.infinity,
        width: 246,
        child: Row(
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: ColoredBox(
                  color: ColorScheme.of(context).secondaryContainer,
                  child: GestureDetector(
                    onTap: () => context.to(() =>
                        UserInfoPage(widget.illust.author.id.toString())),
                    child: AnimatedImage(
                      image: CachedImageProvider(widget.illust.author.avatar),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                widget.illust.author.name,
                maxLines: 2,
              ),
            ),
            if(isFollowing)
              Button(onPressed: follow, child: const SizedBox(
                width: 42,
                height: 24,
                child: Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: ProgressRing(strokeWidth: 2,),
                  ),
                ),
              ))
            else if (!widget.illust.author.isFollowed)
              Button(onPressed: follow, child: Text("Follow".tl))
            else
              Button(
                onPressed: follow,
                child: Text("Unfollow".tl, style: TextStyle(color: ColorScheme.of(context).errorColor),),
              ),
          ],
        ),
      ),
    );
  }

  bool isBookmarking = false;

  Iterable<Widget> buildActions(double width) sync* {
    yield const SizedBox(width: 8,);

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

    void download() {}

    bool showText = width > 640;

    yield Button(
      onPressed: favorite,
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            if(isBookmarking)
              const SizedBox(
                width: 18,
                height: 18,
                child: ProgressRing(strokeWidth: 2,),
              )
            else if(widget.illust.isBookmarked)
              Icon(
                Icons.favorite,
                color: ColorScheme.of(context).errorColor,
                size: 18,
              )
            else
              const Icon(
                Icons.favorite_border,
                size: 18,
              ),
            if(showText)
              const SizedBox(width: 8,),
            if(showText)
              if(widget.illust.isBookmarked)
                Text("Cancel".tl)
              else
                Text("Favorite".tl)
          ],
        ),
      ),
    );

    yield const SizedBox(width: 8,);

    if (!widget.illust.downloaded) {
      yield Button(
        onPressed: download,
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              const Icon(
                FluentIcons.download,
                size: 18,
              ),
              if(showText)
                const SizedBox(width: 8,),
              if(showText)
                Text("Download".tl),
            ],
          ),
        ),
      );
    }

    yield const SizedBox(width: 8,);

    yield Button(
      onPressed: favorite,
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            const Icon(
              FluentIcons.comment,
              size: 18,
            ),
            if(showText)
              const SizedBox(width: 8,),
            if(showText)
              Text("Comment".tl),
          ],
        ),
      ),
    );
  }

  Widget buildStats(){
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 2,),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                  border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6),
                  borderRadius: BorderRadius.circular(4)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.view, size: 20,),
                      Text("Views".tl, style: const TextStyle(fontSize: 12),)
                    ],
                  ),
                  const SizedBox(width: 12,),
                  Text(widget.illust.totalView.toString(), style: TextStyle(color: ColorScheme.of(context).primary, fontWeight: FontWeight.w500, fontSize: 18),)
                ],
              ),
            ),
          ),
          const SizedBox(width: 16,),
          Expanded(child: Container(
            height: 52,
            decoration: BoxDecoration(
                border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6),
                borderRadius: BorderRadius.circular(4)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.six_point_star, size: 20,),
                    Text("Favorites".tl, style: const TextStyle(fontSize: 12),)
                  ],
                ),
                const SizedBox(width: 12,),
                Text(widget.illust.totalBookmarks.toString(), style: TextStyle(color: ColorScheme.of(context).primary, fontWeight: FontWeight.w500, fontSize: 18),)
              ],
            ),
          )),
          const SizedBox(width: 2,),
        ],
      ),
    );
  }

  Widget buildTags() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.illust.tags.map((e) {
          var text = e.name;
          if(e.translatedName != null && e.name != e.translatedName) {
            text += "/${e.translatedName}";
          }
          return Card(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Text(text, style: const TextStyle(fontSize: 13),),
          );
        }).toList(),
      ),
    ).paddingVertical(8).paddingHorizontal(2);
  }
}
