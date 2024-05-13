import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/components/color_scheme.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../network/network.dart';

class UserPreviewWidget extends StatefulWidget {
  const UserPreviewWidget(this.user, {super.key});

  final UserPreview user;

  @override
  State<UserPreviewWidget> createState() => _UserPreviewWidgetState();
}

class _UserPreviewWidgetState extends State<UserPreviewWidget> {
  bool isFollowing = false;

  void follow() async{
    if(isFollowing) return;
    setState(() {
      isFollowing = true;
    });
    var method = widget.user.isFollowed ? "delete" : "add";
    var res = await Network().follow(widget.user.id.toString(), method);
    if(res.error) {
      if(mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      widget.user.isFollowed = !widget.user.isFollowed;
    }
    setState(() {
      isFollowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
          const SizedBox(width: 12,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.name, maxLines: 1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(
                  children: [
                    Button(
                      onPressed: () => context.to(() => UserInfoPage(widget.user.id.toString())),
                      child: Text("View".tl,),
                    ),
                    const SizedBox(width: 8,),
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
                    else if (!widget.user.isFollowed)
                      Button(onPressed: follow, child: Text("Follow".tl))
                    else
                      Button(
                        onPressed: follow,
                        child: Text("Unfollow".tl, style: TextStyle(color: ColorScheme.of(context).errorColor),),
                      ),
                  ],
                )
              ],
            ).paddingVertical(8),
          )
        ],
      ),
    );
  }
}
