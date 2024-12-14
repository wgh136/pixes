import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/history.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/download.dart';
import 'package:pixes/pages/related_page.dart';
import 'package:pixes/utils/translation.dart';

import '../network/network.dart';
import '../pages/illust_page.dart';
import 'md.dart';

typedef UpdateFavoriteFunc = void Function(bool v);

class IllustWidget extends StatefulWidget {
  const IllustWidget(this.illust, {this.onTap, super.key});

  final Illust illust;

  final void Function()? onTap;

  static Map<String, UpdateFavoriteFunc> favoriteCallbacks = {};

  @override
  State<IllustWidget> createState() => _IllustWidgetState();
}

class _IllustWidgetState extends State<IllustWidget> {
  bool isBookmarking = false;

  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();

  @override
  void initState() {
    IllustWidget.favoriteCallbacks[widget.illust.id.toString()] = (v) {
      setState(() {
        widget.illust.isBookmarked = v;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    IllustWidget.favoriteCallbacks.remove(widget.illust.id.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final width = constrains.maxWidth;
      final height = widget.illust.height * width / widget.illust.width;
      return FlyoutTarget(
        controller: contextController,
        child: SizedBox(
          key: contextAttachKey,
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  width: width,
                  height: height,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: FluentTheme.of(context).cardColor,
                      border: () {
                        var emphasis = widget.illust.author.isFollowed &&
                            appdata.settings[
                                'emphasizeArtworksFromFollowingArtists'];
                        var color = emphasis
                            ? ColorScheme.of(context).primary
                            : ColorScheme.of(context)
                                .outlineVariant
                                .toOpacity(0.64);
                        var width = emphasis ? 1.6 : 1.0;
                        return Border.all(color: color, width: width);
                      }(),
                    ),
                    margin: EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: widget.onTap ??
                          () {
                            context.to(() => IllustPage(widget.illust));
                          },
                      onSecondaryTapUp: showMenu,
                      onLongPress: showMenu,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: AnimatedImage(
                          image: CachedImageProvider(
                              widget.illust.images.first.medium),
                          fit: BoxFit.cover,
                          width: width - 16.0,
                          height: height - 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.illust.images.length > 1)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context)
                            .micaBackgroundColor
                            .toOpacity(0.72),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ColorScheme.of(context).outlineVariant,
                            width: 0.6),
                      ),
                      child: Center(
                        child: Text(
                          "${widget.illust.images.length}P",
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                ),
              if (widget.illust.isAi)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context)
                            .errorContainer
                            .toOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ColorScheme.of(context).outlineVariant,
                            width: 0.6),
                      ),
                      child: const Center(
                        child: Text(
                          "AI",
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                ),
              if (widget.illust.isUgoira)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context)
                            .primaryContainer
                            .toOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ColorScheme.of(context).outlineVariant,
                            width: 0.6),
                      ),
                      child: const Center(
                        child: Text(
                          "GIF",
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                ),
              if (widget.illust.isR18)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context).errorContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ColorScheme.of(context).outlineVariant,
                            width: 0.6),
                      ),
                      child: const Center(
                        child: Text(
                          "R18",
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                ),
              if (widget.illust.isR18G)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                      width: 28,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context).errorContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ColorScheme.of(context).outlineVariant,
                            width: 0.6),
                      ),
                      child: const Center(
                        child: Text(
                          "R18G",
                          style: TextStyle(fontSize: 12),
                        ),
                      )),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: buildButton(),
              )
            ],
          ),
        ),
      );
    });
  }

  void showMenu([TapUpDetails? details]) {
    // This calculates the position of the flyout according to the parent navigator
    final targetContext = contextAttachKey.currentContext;
    if (targetContext == null) return;
    final box = targetContext.findRenderObject() as RenderBox;
    Offset? position = box.localToGlobal(
      details?.localPosition ?? box.size.center(Offset.zero),
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    contextController.showFlyout(
      barrierColor: Colors.transparent,
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
                text: Text("View".tl),
                onPressed: () {
                  context.to(() => IllustPage(widget.illust));
                }),
            MenuFlyoutItem(
                text: Text("Private Favorite".tl),
                onPressed: () {
                  favorite("private");
                }),
            MenuFlyoutItem(
                text: Text("Download".tl),
                onPressed: () {
                  context.showToast(message: "Added");
                  DownloadManager().addDownloadingTask(widget.illust);
                }),
            MenuFlyoutItem(
                text: Text("Related Artworks".tl),
                onPressed: () {
                  context.to(
                      () => RelatedIllustsPage(widget.illust.id.toString()));
                }),
          ],
        );
      },
    );
  }

  void favorite([String type = "public"]) async {
    if (isBookmarking) return;
    setState(() {
      isBookmarking = true;
    });
    var method = widget.illust.isBookmarked ? "delete" : "add";
    var res =
        await Network().addBookmark(widget.illust.id.toString(), method, type);
    if (res.error) {
      if (mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      widget.illust.isBookmarked = !widget.illust.isBookmarked;
    }
    setState(() {
      isBookmarking = false;
    });
  }

  Widget buildButton() {
    Widget child;
    if (isBookmarking) {
      child = const SizedBox(
        width: 14,
        height: 14,
        child: ProgressRing(
          strokeWidth: 1.6,
        ),
      );
    } else if (widget.illust.isBookmarked) {
      child = Icon(
        MdIcons.favorite,
        color: Colors.red,
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

class IllustHistoryWidget extends StatelessWidget {
  const IllustHistoryWidget(this.illust, {super.key});

  final IllustHistory illust;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final width = constrains.maxWidth;
      final height = illust.height * width / illust.width;
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
              width: width,
              height: height,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Card(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: GestureDetector(
                  onTap: () {
                    context.to(() => IllustPageWithId(illust.id.toString()));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: AnimatedImage(
                      image: CachedImageProvider(illust.imgPath),
                      fit: BoxFit.cover,
                      width: width - 16.0,
                      height: height - 16.0,
                    ),
                  ),
                ),
              ),
            )),
            if (illust.imageCount > 1)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context)
                          .micaBackgroundColor
                          .toOpacity(0.72),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorScheme.of(context).outlineVariant,
                          width: 0.6),
                    ),
                    child: Center(
                      child: Text(
                        "${illust.imageCount}P",
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
              ),
            if (illust.isAi)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context)
                          .errorContainer
                          .toOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorScheme.of(context).outlineVariant,
                          width: 0.6),
                    ),
                    child: const Center(
                      child: Text(
                        "AI",
                        style: TextStyle(fontSize: 12),
                      ),
                    )),
              ),
            if (illust.isGif)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context)
                          .primaryContainer
                          .toOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorScheme.of(context).outlineVariant,
                          width: 0.6),
                    ),
                    child: const Center(
                      child: Text(
                        "GIF",
                        style: TextStyle(fontSize: 12),
                      ),
                    )),
              ),
            if (illust.isR18)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).errorContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorScheme.of(context).outlineVariant,
                          width: 0.6),
                    ),
                    child: const Center(
                      child: Text(
                        "R18",
                        style: TextStyle(fontSize: 12),
                      ),
                    )),
              ),
            if (illust.isR18G)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).errorContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ColorScheme.of(context).outlineVariant,
                          width: 0.6),
                    ),
                    child: const Center(
                      child: Text(
                        "R18G",
                        style: TextStyle(fontSize: 12),
                      ),
                    )),
              ),
          ],
        ),
      );
    });
  }
}
