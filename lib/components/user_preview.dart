import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/pages/illust_page.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../network/network.dart';
import 'md.dart';

typedef UpdateFollowCallback = void Function(bool isFollowed);

class UserPreviewWidget extends StatefulWidget {
  const UserPreviewWidget(this.user, {super.key});

  final UserPreview user;

  static Map<String, UpdateFollowCallback> followCallbacks = {};

  @override
  State<UserPreviewWidget> createState() => _UserPreviewWidgetState();
}

class _UserPreviewWidgetState extends State<UserPreviewWidget> {
  @override
  void initState() {
    UserPreviewWidget.followCallbacks[widget.user.id.toString()] = (v) {
      setState(() {
        widget.user.isFollowed = v;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    UserPreviewWidget.followCallbacks.remove(widget.user.id.toString());
    super.dispose();
  }

  bool isFollowing = false;

  void follow() async {
    if (isFollowing) return;
    setState(() {
      isFollowing = true;
    });
    var method = widget.user.isFollowed ? "delete" : "add";
    var res = await Network().follow(widget.user.id.toString(), method);
    if (res.error) {
      if (mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      widget.user.isFollowed = !widget.user.isFollowed;
    }
    setState(() {
      isFollowing = false;
    });
    UserInfoPage.followCallbacks[widget.user.id.toString()]
        ?.call(widget.user.isFollowed);
    IllustPage.updateFollow(widget.user.id.toString(), widget.user.isFollowed);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: GestureDetector(
        onTap: () => context.to(() => UserInfoPage(widget.user.id.toString())),
        behavior: HitTestBehavior.translucent,
        child: SizedBox.expand(
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: ColoredBox(
                    color: ColorScheme.of(context).secondaryContainer,
                    child: AnimatedImage(
                      image: CachedImageProvider(widget.user.avatar),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(widget.user.name,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        if (isFollowing)
                          Button(
                              onPressed: follow,
                              child: const SizedBox(
                                width: 42,
                                height: 24,
                                child: Center(
                                  child: SizedBox.square(
                                    dimension: 18,
                                    child: ProgressRing(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ))
                        else if (!widget.user.isFollowed)
                          Button(onPressed: follow, child: Text("Follow".tl))
                        else
                          Button(
                            onPressed: follow,
                            child: Text(
                              "Unfollow".tl,
                              style: TextStyle(
                                  color: ColorScheme.of(context).error),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    var count = constraints.maxWidth.toInt() ~/ 96;
                    var images = List.generate(
                        min(count, widget.user.artworks.length),
                        (index) => buildIllust(widget.user.artworks[index]));
                    return Row(
                      children: images,
                    );
                  },
                ),
              ),
              const Icon(
                FluentIcons.chevron_right,
                size: 14,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIllust(Illust illust) {
    return SizedBox(
      width: 96,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ColoredBox(
            color: ColorScheme.of(context).secondaryContainer,
            child: AnimatedImage(
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              image: CachedImageProvider(illust.images.first.medium),
            ),
          ),
        ),
      ),
    );
  }
}
