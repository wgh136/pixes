import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/message.dart';
import 'package:pixes/components/novel.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/components/user_preview.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/illust_page.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../components/animated_image.dart';
import '../components/grid.dart';
import '../components/illust_widget.dart';
import '../components/md.dart';
import '../foundation/image_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String text = "";

  int searchType = 0;

  static const searchTypes = [
    "Search artwork",
    "Search novel",
    "Search user",
    "Artwork ID",
    "Artist ID",
    "Novel ID"
  ];

  void search() {
    switch (searchType) {
      case 0:
        context.to(() => SearchResultPage(text));
      case 1:
        context.to(() => SearchNovelResultPage(text));
      case 2:
        context.to(() => SearchUserResultPage(text));
      case 3:
        context.to(() => IllustPageWithId(text));
      case 4:
        context.to(() => UserInfoPage(text));
      case 5:
        showToast(context, message: "Not implemented");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: const EdgeInsets.only(top: 8),
      content: Column(
        children: [
          buildSearchBar(),
          const SizedBox(
            height: 8,
          ),
          const Expanded(
            child: _TrendingTagsView(),
          )
        ],
      ),
    );
  }

  final optionController = FlyoutController();

  Widget buildSearchBar() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SizedBox(
        height: 42,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constrains) {
            return SizedBox(
              height: 42,
              width: constrains.maxWidth,
              child: Row(
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: searchTypes[searchType].tl,
                      onChanged: (s) => text = s,
                      onSubmitted: (s) => search(),
                      foregroundDecoration: BoxDecoration(
                          border: Border.all(
                              color: ColorScheme.of(context)
                                  .outlineVariant
                                  .withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(4)),
                      suffix: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: search,
                          child: const Icon(
                            FluentIcons.search,
                            size: 16,
                          ).paddingHorizontal(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  FlyoutTarget(
                    controller: optionController,
                    child: Button(
                      child: const SizedBox(
                        height: 42,
                        child: Center(
                          child: Icon(FluentIcons.chevron_down),
                        ),
                      ),
                      onPressed: () {
                        optionController.showFlyout(
                          navigatorKey: App.rootNavigatorKey.currentState,
                          placementMode: FlyoutPlacementMode.bottomCenter,
                          builder: buildSearchOption,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Button(
                    child: const SizedBox(
                      height: 42,
                      child: Center(
                        child: Icon(FluentIcons.settings),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(SideBarRoute(SearchSettings(
                        isNovel: searchType == 1,
                      )));
                    },
                  )
                ],
              ),
            );
          },
        ),
      ).paddingHorizontal(16),
    );
  }

  Widget buildSearchOption(BuildContext context) {
    return MenuFlyout(
      items: List.generate(
          searchTypes.length,
          (index) => MenuFlyoutItem(
              text: Text(searchTypes[index].tl),
              onPressed: () => setState(() => searchType = index))),
    );
  }
}

class _TrendingTagsView extends StatefulWidget {
  const _TrendingTagsView();

  @override
  State<_TrendingTagsView> createState() => _TrendingTagsViewState();
}

class _TrendingTagsViewState
    extends LoadingState<_TrendingTagsView, List<TrendingTag>> {
  @override
  Widget buildContent(BuildContext context, List<TrendingTag> data) {
    return MasonryGridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0) +
          EdgeInsets.only(bottom: context.padding.bottom),
      gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return buildItem(data[index]);
      },
    );
  }

  Widget buildItem(TrendingTag tag) {
    final illust = tag.illust;

    var text = tag.tag.name;
    if (tag.tag.translatedName != null) {
      text += "/${tag.tag.translatedName}";
    }

    return LayoutBuilder(builder: (context, constrains) {
      final width = constrains.maxWidth;
      final height = illust.height * width / illust.width;
      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Card(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.to(() => SearchResultPage(tag.tag.name));
              },
              child: Stack(
                children: [
                  Positioned.fill(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: AnimatedImage(
                      image: CachedImageProvider(illust.images.first.medium),
                      fit: BoxFit.cover,
                      width: width - 16.0,
                      height: height - 16.0,
                    ),
                  )),
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: FluentTheme.of(context)
                              .micaBackgroundColor
                              .withOpacity(0.84),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(text)
                          .paddingHorizontal(4)
                          .paddingVertical(6)
                          .paddingBottom(2),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Future<Res<List<TrendingTag>>> loadData() {
    return Network().getHotTags();
  }
}

class SearchSettings extends StatefulWidget {
  const SearchSettings({this.onChanged, this.isNovel = false, super.key});

  final void Function()? onChanged;

  final bool isNovel;

  @override
  State<SearchSettings> createState() => _SearchSettingsState();
}

class _SearchSettingsState extends State<SearchSettings> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              "Search Settings".tl,
              style: const TextStyle(fontSize: 18),
            ),
          ).toAlign(Alignment.centerLeft),
          buildItem(
              title: "Match".tl,
              child: DropDownButton(
                title: Text(appdata.searchOptions.matchType.toString().tl),
                items: KeywordMatchType.values
                    .map((e) => MenuFlyoutItem(
                        text: Text(e.toString().tl),
                        onPressed: () {
                          if (appdata.searchOptions.matchType != e) {
                            setState(() => appdata.searchOptions.matchType = e);
                            widget.onChanged?.call();
                          }
                        }))
                    .toList(),
              )),
          if (!widget.isNovel)
            buildItem(
                title: "Favorite number".tl,
                child: DropDownButton(
                  title:
                      Text(appdata.searchOptions.favoriteNumber.toString().tl),
                  items: FavoriteNumber.values
                      .map((e) => MenuFlyoutItem(
                          text: Text(e.toString().tl),
                          onPressed: () {
                            if (appdata.searchOptions.favoriteNumber != e) {
                              setState(() =>
                                  appdata.searchOptions.favoriteNumber = e);
                              widget.onChanged?.call();
                            }
                          }))
                      .toList(),
                )),
          buildItem(
              title: "Sort".tl,
              child: DropDownButton(
                title: Text(appdata.searchOptions.sort.toString().tl),
                items: SearchSort.values
                    .map((e) => MenuFlyoutItem(
                        text: Text(e.toString().tl),
                        onPressed: () {
                          if (appdata.searchOptions.sort != e) {
                            setState(() => appdata.searchOptions.sort = e);
                            widget.onChanged?.call();
                          }
                        }))
                    .toList(),
              )),
          if (!widget.isNovel)
            Card(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "Start Time".tl,
                        style: const TextStyle(fontSize: 16),
                      )
                          .paddingVertical(8)
                          .toAlign(Alignment.centerLeft)
                          .paddingLeft(16),
                      DatePicker(
                        selected: appdata.searchOptions.startTime,
                        onChanged: (t) {
                          if (appdata.searchOptions.startTime != t) {
                            setState(() => appdata.searchOptions.startTime = t);
                            widget.onChanged?.call();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      )
                    ],
                  ),
                )),
          if (!widget.isNovel)
            Card(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "End Time".tl,
                        style: const TextStyle(fontSize: 16),
                      )
                          .paddingVertical(8)
                          .toAlign(Alignment.centerLeft)
                          .paddingLeft(16),
                      DatePicker(
                        selected: appdata.searchOptions.endTime,
                        onChanged: (t) {
                          if (appdata.searchOptions.endTime != t) {
                            setState(() => appdata.searchOptions.endTime = t);
                            widget.onChanged?.call();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      )
                    ],
                  ),
                )),
          if (!widget.isNovel)
            buildItem(
                title: "Age limit".tl,
                child: DropDownButton(
                  title: Text(appdata.searchOptions.ageLimit.toString().tl),
                  items: AgeLimit.values
                      .map((e) => MenuFlyoutItem(
                          text: Text(e.toString().tl),
                          onPressed: () {
                            if (appdata.searchOptions.ageLimit != e) {
                              setState(
                                  () => appdata.searchOptions.ageLimit = e);
                              widget.onChanged?.call();
                            }
                          }))
                      .toList(),
                )),
          SizedBox(
            height: context.padding.bottom,
          )
        ],
      ),
    );
  }

  Widget buildItem({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text(title),
        trailing: child,
      ),
    );
  }
}

class SearchResultPage extends StatefulWidget {
  const SearchResultPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState
    extends MultiPageLoadingState<SearchResultPage, Illust> {
  late String keyword = widget.keyword;

  late String oldKeyword = widget.keyword;

  late final controller = TextEditingController(text: widget.keyword);

  void search() {
    if (keyword != oldKeyword) {
      oldKeyword = keyword;
      reset();
    }
  }

  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return CustomScrollView(
      slivers: [
        buildSearchBar(),
        SliverMasonryGrid(
          gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == data.length - 1) {
                nextPage();
              }
              return IllustWidget(
                data[index],
                onTap: () {
                  context.to(() => IllustGalleryPage(
                      illusts: data, initialPage: index, nextUrl: nextUrl));
                },
              );
            },
            childCount: data.length,
          ),
        ).sliverPaddingHorizontal(8),
        SliverPadding(
          padding: EdgeInsets.only(bottom: context.padding.bottom),
        )
      ],
    );
  }

  Widget buildSearchBar() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            height: 42,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constrains) {
                return SizedBox(
                  height: 42,
                  width: constrains.maxWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextBox(
                          controller: controller,
                          placeholder: "Search artworks".tl,
                          onChanged: (s) => keyword = s,
                          onSubmitted: (s) => search(),
                          foregroundDecoration: BoxDecoration(
                              border: Border.all(
                                  color: ColorScheme.of(context)
                                      .outlineVariant
                                      .withOpacity(0.6)),
                              borderRadius: BorderRadius.circular(4)),
                          suffix: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: search,
                              child: const Icon(
                                FluentIcons.search,
                                size: 16,
                              ).paddingHorizontal(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Button(
                        child: const SizedBox(
                          height: 42,
                          child: Center(
                            child: Icon(FluentIcons.settings),
                          ),
                        ),
                        onPressed: () async {
                          bool isChanged = false;
                          await Navigator.of(context)
                              .push(SideBarRoute(SearchSettings(
                            onChanged: () => isChanged = true,
                          )));
                          if (isChanged) {
                            reset();
                          }
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ).paddingHorizontal(16),
        ),
      ),
    ).sliverPadding(const EdgeInsets.only(top: 12));
  }

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? await Network().search(keyword, appdata.searchOptions)
        : await Network().getIllustsWithNextUrl(nextUrl!);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

class SearchUserResultPage extends StatefulWidget {
  const SearchUserResultPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<SearchUserResultPage> createState() => _SearchUserResultPageState();
}

class _SearchUserResultPageState
    extends MultiPageLoadingState<SearchUserResultPage, UserPreview> {
  @override
  Widget buildContent(BuildContext context, final List<UserPreview> data) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text(
            "${"Search".tl}: ${widget.keyword}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ).paddingVertical(12).paddingHorizontal(16),
        ),
        SliverGridViewWithFixedItemHeight(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == data.length - 1) {
              nextPage();
            }
            return UserPreviewWidget(data[index]);
          }, childCount: data.length),
          minCrossAxisExtent: 440,
          itemHeight: 136,
        ).sliverPaddingHorizontal(8),
        SliverPadding(
          padding: EdgeInsets.only(bottom: context.padding.bottom),
        )
      ],
    );
  }

  String? nextUrl;

  @override
  Future<Res<List<UserPreview>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = await Network().searchUsers(widget.keyword, nextUrl);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

class SearchNovelResultPage extends StatefulWidget {
  const SearchNovelResultPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<SearchNovelResultPage> createState() => _SearchNovelResultPageState();
}

class _SearchNovelResultPageState
    extends MultiPageLoadingState<SearchNovelResultPage, Novel> {
  late String keyword = widget.keyword;

  late String oldKeyword = widget.keyword;

  late final controller = TextEditingController(text: widget.keyword);

  void search() {
    if (keyword != oldKeyword) {
      oldKeyword = keyword;
      reset();
    }
  }

  @override
  Widget buildContent(BuildContext context, final List<Novel> data) {
    return CustomScrollView(
      slivers: [
        buildSearchBar(),
        SliverGridViewWithFixedItemHeight(
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
        ).sliverPaddingHorizontal(8),
        SliverPadding(
          padding: EdgeInsets.only(bottom: context.padding.bottom),
        )
      ],
    );
  }

  Widget buildSearchBar() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            height: 42,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constrains) {
                return SizedBox(
                  height: 42,
                  width: constrains.maxWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextBox(
                          controller: controller,
                          placeholder: "Search artworks".tl,
                          onChanged: (s) => keyword = s,
                          onSubmitted: (s) => search(),
                          foregroundDecoration: BoxDecoration(
                              border: Border.all(
                                  color: ColorScheme.of(context)
                                      .outlineVariant
                                      .withOpacity(0.6)),
                              borderRadius: BorderRadius.circular(4)),
                          suffix: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: search,
                              child: const Icon(
                                FluentIcons.search,
                                size: 16,
                              ).paddingHorizontal(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Button(
                        child: const SizedBox(
                          height: 42,
                          child: Center(
                            child: Icon(FluentIcons.settings),
                          ),
                        ),
                        onPressed: () async {
                          bool isChanged = false;
                          await Navigator.of(context)
                              .push(SideBarRoute(SearchSettings(
                            onChanged: () => isChanged = true,
                            isNovel: true,
                          )));
                          if (isChanged) {
                            reset();
                          }
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ).paddingHorizontal(16),
        ),
      ),
    ).sliverPadding(const EdgeInsets.only(top: 12));
  }

  String? nextUrl;

  @override
  Future<Res<List<Novel>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? await Network().searchNovels(keyword, appdata.searchOptions)
        : await Network().getNovelsWithNextUrl(nextUrl!);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}
