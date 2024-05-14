import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/following_users_page.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/illust_widget.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage(this.id, {this.followCallback, super.key});

  final String id;

  final void Function(bool)? followCallback;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends LoadingState<UserInfoPage, UserDetails> {
  @override
  Widget buildContent(BuildContext context, UserDetails data) {
    return ScaffoldPage(
      content: CustomScrollView(
        slivers: [
          buildUser(),
          buildInformation(),
          SliverToBoxAdapter(child: buildHeader("Artworks"),),
          _UserArtworks(data.id.toString(), key: ValueKey(data.id),),
        ],
      ),
    );
  }

  bool isFollowing = false;

  void follow() async{
    if(isFollowing) return;
    String type = "";
    if(!data!.isFollowed) {
      await flyoutController.showFlyout(
          navigatorKey: App.rootNavigatorKey.currentState,
          builder: (context) =>
              MenuFlyout(
                items: [
                  MenuFlyoutItem(text: Text("Public".tl),
                      onPressed: () => type = "public"),
                  MenuFlyoutItem(text: Text("Private".tl),
                      onPressed: () => type = "private"),
                ],
              ));
    }
    if(type.isEmpty && !data!.isFollowed) {
      return;
    }
    setState(() {
      isFollowing = true;
    });
    var method = data!.isFollowed ? "delete" : "add";
    var res = await Network().follow(data!.id.toString(), method, type);
    if(res.error) {
      if(mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      data!.isFollowed = !data!.isFollowed;
      widget.followCallback?.call(data!.isFollowed);
    }
    setState(() {
      isFollowing = false;
    });
  }

  var flyoutController = FlyoutController();

  Widget buildUser() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Image(
                image: CachedImageProvider(data!.avatar),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),),
          const SizedBox(height: 8),
          Text(data!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Follows: '.tl),
                TextSpan(
                  text: '${data!.totalFollowUsers}',
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() => context.to(() => FollowingUsersPage(widget.id))),
                  style: TextStyle(fontWeight: FontWeight.bold, color: FluentTheme.of(context).accentColor)
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
          if(widget.id != appdata.account?.user.id)
            const SizedBox(height: 8,),
          if(widget.id != appdata.account?.user.id)
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
            else if (!data!.isFollowed)
              FlyoutTarget(
                controller: flyoutController,
                child: Button(onPressed: follow, child: Text("Follow".tl))
              )
            else
              Button(
                onPressed: follow,
                child: Text("Unfollow".tl, style: TextStyle(color: ColorScheme.of(context).error),),
              ),
        ],
      ),
    );
  }

  Widget buildHeader(String title) {
    return SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ).toAlign(Alignment.centerLeft)).paddingLeft(16).paddingVertical(4);
  }

  Widget buildInformation() {
    Widget buildItem({IconData? icon, required String title, required String? content, Widget? trailing}) {
      if(content == null || content.isEmpty) {
        return const SizedBox.shrink();
      }
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: icon == null ? null : Icon(icon, size: 20,),
          title: Text(title),
          subtitle: SelectableText(content),
          trailing: trailing,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildHeader("Information".tl),
          buildItem(icon: MdIcons.comment_outlined, title: "Introduction".tl, content: data!.comment),
          buildItem(icon: MdIcons.cake_outlined, title: "Birthday".tl, content: data!.birth),
          buildItem(icon: MdIcons.location_city_outlined, title: "Region", content: data!.region),
          buildItem(icon: MdIcons.work_outline, title: "Job".tl, content: data!.job),
          buildItem(icon: MdIcons.person_2_outlined, title: "Gender".tl, content: data!.gender),
          const SizedBox(height: 8,),
          buildHeader("Social Network".tl),
          buildItem(title: "Webpage",
              content: data!.webpage,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!)
              )),
          buildItem(title: "Twitter",
              content: data!.twitterUrl,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!)
              )),
          buildItem(title: "pawoo",
              content: data!.pawooUrl,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18,),
                  onPressed: () => launchUrlString(data!.pawooUrl!)
              )),
        ],
      ),
    );
  }

  @override
  Future<Res<UserDetails>> loadData() {
    return Network().getUserDetails(widget.id);
  }
}

class _UserArtworks extends StatefulWidget {
  const _UserArtworks(this.uid, {super.key});

  final String uid;

  @override
  State<_UserArtworks> createState() => _UserArtworksState();
}

class _UserArtworksState extends MultiPageLoadingState<_UserArtworks, Illust> {
  @override
  Widget buildLoading(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(
        child: Center(
          child: ProgressRing(),
        ),
      ),
    );
  }

  @override
  Widget buildError(context, error) {
    return SliverToBoxAdapter(
      child: SizedBox(
        child: Center(
          child: Row(
            children: [
              const Icon(FluentIcons.info),
              const SizedBox(width: 4,),
              Text(error)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if(index == data.length - 1){
            nextPage();
          }
          return IllustWidget(data[index]);
        },
        childCount: data.length,
      ),
    ).sliverPaddingHorizontal(8);
  }

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async{
    if(nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? await Network().getUserIllusts(widget.uid)
        : await Network().getIllustsWithNextUrl(nextUrl!);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

