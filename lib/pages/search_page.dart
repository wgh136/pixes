import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../components/animated_image.dart';
import '../components/color_scheme.dart';
import '../foundation/image_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String text = "";

  int searchType = 0;

  void search() {
    switch(searchType) {
      case 0:
        context.to(() => SearchResultPage(text));
      case 1:
        // TODO: artwork by id
        throw UnimplementedError();
      case 2:
        context.to(() => UserInfoPage(text));
      case 3:
        // TODO: novel page
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Column(
        children: [
          buildSearchBar(),
          const SizedBox(height: 8,),
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
                          builder: buildSearchOption,
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ).paddingHorizontal(16),
    );
  }

  static const searchTypes = [
    "Keyword search",
    "Artwork ID",
    "Artist ID",
    "Novel ID"
  ];

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

class _TrendingTagsViewState extends LoadingState<_TrendingTagsView, List<TrendingTag>> {
  @override
  Widget buildContent(BuildContext context, List<TrendingTag> data) {
    return MasonryGridView.builder(
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
    if(tag.tag.translatedName != null) {
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
              onTap: (){
                context.to(() => SearchResultPage(tag.tag.name));
              },
              child: Stack(
                children: [
                  Positioned.fill(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: AnimatedImage(
                      image: CachedImageProvider(illust.images.first.medium),
                      fit: BoxFit.cover,
                      width: width-16.0,
                      height: height-16.0,
                    ),
                  )),
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor.withOpacity(0.84),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(text).paddingHorizontal(4).paddingVertical(6).paddingBottom(2),
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


class SearchResultPage extends StatefulWidget {
  const SearchResultPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage();
  }
}

