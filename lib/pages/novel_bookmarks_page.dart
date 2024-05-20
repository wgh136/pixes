import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/grid.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/novel.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/widget_utils.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

class NovelBookmarksPage extends StatefulWidget {
  const NovelBookmarksPage({super.key});

  @override
  State<NovelBookmarksPage> createState() => _NovelBookmarksPageState();
}

class _NovelBookmarksPageState
    extends MultiPageLoadingState<NovelBookmarksPage, Novel> {
  @override
  Widget buildContent(BuildContext context, List<Novel> data) {
    return Column(
      children: [
        TitleBar(title: "Bookmarks".tl),
        Expanded(
          child: GridViewWithFixedItemHeight(
            itemCount: data.length,
            itemHeight: 164,
            minCrossAxisExtent: 400,
            builder: (context, index) {
              if (index == data.length - 1) {
                nextPage();
              }
              return NovelWidget(data[index]);
            },
          ).paddingHorizontal(8),
        )
      ],
    );
  }

  String? nextUrl;

  @override
  Future<Res<List<Novel>>> loadData(int page) async {
    if (nextUrl == "end") return Res.error("No more data");
    var res = nextUrl == null
        ? await Network().getBookmarkedNovels(appdata.account!.user.id)
        : await Network().getNovelsWithNextUrl(nextUrl!);
    nextUrl = res.subData ?? "end";
    return res;
  }
}
