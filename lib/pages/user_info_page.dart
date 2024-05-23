import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/batch_download.dart';
import 'package:pixes/components/grid.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/novel.dart';
import 'package:pixes/components/segmented_button.dart';
import 'package:pixes/components/user_preview.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/following_users_page.dart';
import 'package:pixes/utils/block.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/illust_widget.dart';
import 'illust_page.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage(this.id, {super.key});

  final String id;

  static Map<String, UpdateFollowCallback> followCallbacks = {};

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends LoadingState<UserInfoPage, UserDetails> {
  @override
  void initState() {
    UserInfoPage.followCallbacks[widget.id] = (v) {
      if (data == null) return;
      setState(() {
        data!.isFollowed = v;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    UserInfoPage.followCallbacks.remove(widget.id);
    super.dispose();
  }

  int page = 0;

  @override
  Widget buildContent(BuildContext context, UserDetails data) {
    return ScaffoldPage(
      content: CustomScrollView(
        slivers: [
          buildUser(),
          SliverToBoxAdapter(
            child: buildHeader("Related users".tl),
          ),
          _RelatedUsers(widget.id),
          buildInformation(),
          buildArtworkHeader(),
          if (page == 2)
            _UserNovels(widget.id)
          else
            _UserArtworks(
              data.id.toString(),
              page,
              key: ValueKey(data.id + page),
            ),
          SliverPadding(
              padding: EdgeInsets.only(bottom: context.padding.bottom)),
        ],
      ),
    );
  }

  bool isFollowing = false;

  void follow() async {
    if (isFollowing) return;
    String type = "";
    if (!data!.isFollowed) {
      await flyoutController.showFlyout(
          navigatorKey: App.rootNavigatorKey.currentState,
          builder: (context) => MenuFlyout(
                items: [
                  MenuFlyoutItem(
                      text: Text("Public".tl),
                      onPressed: () => type = "public"),
                  MenuFlyoutItem(
                      text: Text("Private".tl),
                      onPressed: () => type = "private"),
                ],
              ));
    }
    if (type.isEmpty && !data!.isFollowed) {
      return;
    }
    setState(() {
      isFollowing = true;
    });
    var method = data!.isFollowed ? "delete" : "add";
    var res = await Network().follow(data!.id.toString(), method, type);
    if (res.error) {
      if (mounted) {
        context.showToast(message: "Network Error");
      }
    } else {
      data!.isFollowed = !data!.isFollowed;
      UserPreviewWidget.followCallbacks[data!.id.toString()]
          ?.call(data!.isFollowed);
      IllustPage.updateFollow(data!.id.toString(), data!.isFollowed);
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
                border: Border.all(
                    color: ColorScheme.of(context).outlineVariant, width: 0.6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Image(
                image: CachedImageProvider(data!.avatar),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(data!.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Follows: '.tl),
                TextSpan(
                    text: '${data!.totalFollowUsers}',
                    recognizer: TapGestureRecognizer()
                      ..onTap = (() =>
                          context.to(() => FollowingUsersPage(widget.id))),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: FluentTheme.of(context).accentColor)),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
          if (widget.id != appdata.account?.user.id)
            const SizedBox(
              height: 8,
            ),
          if (widget.id != appdata.account?.user.id)
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
            else if (!data!.isFollowed)
              FlyoutTarget(
                  controller: flyoutController,
                  child: Button(onPressed: follow, child: Text("Follow".tl)))
            else
              Button(
                onPressed: follow,
                child: Text(
                  "Unfollow".tl,
                  style: TextStyle(color: ColorScheme.of(context).error),
                ),
              ),
        ],
      ),
    );
  }

  Widget buildHeader(String title, {Widget? action}) {
    return SizedBox(
            width: double.infinity,
            height: 38,
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ).toAlign(Alignment.centerLeft),
                const Spacer(),
                if (action != null) action.toAlign(Alignment.centerRight)
              ],
            ).paddingHorizontal(16))
        .paddingTop(8);
  }

  Widget buildArtworkHeader() {
    return SliverToBoxAdapter(
      child: SizedBox(
              width: double.infinity,
              height: 38,
              child: Row(
                children: [
                  SegmentedButton<int>(
                    options: [
                      SegmentedButtonOption(0, "Artworks".tl),
                      SegmentedButtonOption(1, "Bookmarks".tl),
                      SegmentedButtonOption(2, "Novels".tl),
                    ],
                    value: page,
                    onPressed: (value) {
                      setState(() {
                        page = value;
                      });
                    },
                  ),
                  const Spacer(),
                  if (page != 2)
                    BatchDownloadButton(
                      request: () {
                        if (page == 0) {
                          return Network().getUserIllusts(data!.id.toString());
                        } else {
                          return Network()
                              .getUserBookmarks(data!.id.toString());
                        }
                      },
                    ),
                ],
              ).paddingHorizontal(16))
          .paddingTop(12),
    );
  }

  Widget buildInformation() {
    Widget buildItem(
        {IconData? icon,
        required String title,
        required String? content,
        Widget? trailing}) {
      if (content == null || content.isEmpty) {
        return const SizedBox.shrink();
      }
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: icon == null
              ? null
              : Icon(
                  icon,
                  size: 20,
                ),
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
          buildItem(
              icon: MdIcons.comment_outlined,
              title: "Introduction".tl,
              content: data!.comment),
          buildItem(
              icon: MdIcons.cake_outlined,
              title: "Birthday".tl,
              content: data!.birth),
          buildItem(
              icon: MdIcons.location_city_outlined,
              title: "Region",
              content: data!.region),
          buildItem(
              icon: MdIcons.work_outline, title: "Job".tl, content: data!.job),
          buildItem(
              icon: MdIcons.person_2_outlined,
              title: "Gender".tl,
              content: data!.gender),
          buildHeader("Social Network".tl),
          buildItem(
              title: "Webpage",
              content: data!.webpage,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!))),
          buildItem(
              title: "Twitter",
              content: data!.twitterUrl,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!))),
          buildItem(
              title: "pawoo",
              content: data!.pawooUrl,
              trailing: IconButton(
                  icon: const Icon(
                    MdIcons.open_in_new,
                    size: 18,
                  ),
                  onPressed: () => launchUrlString(data!.pawooUrl!))),
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
  const _UserArtworks(this.uid, this.type, {super.key});

  final String uid;

  final int type;

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
              const SizedBox(
                width: 4,
              ),
              Text(error)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<Illust> data) {
    checkIllusts(data);
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == data.length - 1) {
            nextPage();
          }
          return IllustWidget(data[index], onTap: () {
            context.to(() => IllustGalleryPage(
                illusts: data, initialPage: index, nextUrl: nextUrl));
          });
        },
        childCount: data.length,
      ),
    ).sliverPaddingHorizontal(8);
  }

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? (widget.type == 0
            ? await Network().getUserIllusts(widget.uid)
            : await Network().getUserBookmarks(widget.uid))
        : await Network().getIllustsWithNextUrl(nextUrl!);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

class _UserNovels extends StatefulWidget {
  const _UserNovels(this.uid, {super.key});

  final String uid;

  @override
  State<_UserNovels> createState() => _UserNovelsState();
}

class _UserNovelsState extends MultiPageLoadingState<_UserNovels, Novel> {
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
              const SizedBox(
                width: 4,
              ),
              Text(error)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<Novel> data) {
    return SliverGridViewWithFixedItemHeight(
      itemHeight: 164,
      minCrossAxisExtent: 400,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == data.length - 1) {
            nextPage();
          }
          return NovelWidget(data[index]);
        },
        childCount: data.length,
      ),
    ).sliverPaddingHorizontal(8);
  }

  String? nextUrl;

  @override
  Future<Res<List<Novel>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? await Network().getUserNovels(widget.uid)
        : await Network().getNovelsWithNextUrl(nextUrl!);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

class _RelatedUsers extends StatefulWidget {
  const _RelatedUsers(this.uid);

  final String uid;

  @override
  State<_RelatedUsers> createState() => _RelatedUsersState();
}

class _RelatedUsersState
    extends LoadingState<_RelatedUsers, List<UserPreview>> {
  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 146,
        width: double.infinity,
        child: child,
      ),
    );
  }

  final ScrollController _controller = ScrollController();

  @override
  Widget buildContent(BuildContext context, List<UserPreview> data) {
    Widget content = Scrollbar(
        controller: _controller,
        child: ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.only(bottom: 8, left: 8),
          primary: false,
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return UserPreviewWidget(data[index]).fixWidth(342);
          },
        ));
    if (MediaQuery.of(context).size.width > 500) {
      content = ScrollbarTheme.merge(
          data: const ScrollbarThemeData(
              thickness: 6,
              hoveringThickness: 6,
              mainAxisMargin: 4,
              hoveringPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              hoveringMainAxisMargin: 4),
          child: content);
    }
    return MediaQuery.removePadding(
        context: context, removeBottom: true, child: content);
  }

  @override
  Future<Res<List<UserPreview>>> loadData() {
    return Network().relatedUsers(widget.uid);
  }
}
