import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/novel.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

import '../components/grid.dart';

class NovelRankingPage extends StatefulWidget {
  const NovelRankingPage({super.key});

  @override
  State<NovelRankingPage> createState() => _NovelRankingPageState();
}

class _NovelRankingPageState extends State<NovelRankingPage> {
  String type = "day";

  /// mode: day, day_male, day_female, week_rookie, week, week_ai
  static const types = {
    "day": "Daily",
    "week": "Weekly",
    "day_male": "For male",
    "day_female": "For female",
    "week_rookie": "Rookies",
  };

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          buildHeader(),
          Expanded(
            child: _OneRankingPage(
              type,
              key: Key(type),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return TitleBar(
      title: "Ranking".tl,
      action: DropDownButton(
        title: Text(types[type]!.tl),
        items: types.entries
            .map((e) => MenuFlyoutItem(
                  text: Text(e.value.tl),
                  onPressed: () {
                    setState(() {
                      type = e.key;
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _OneRankingPage extends StatefulWidget {
  const _OneRankingPage(this.type, {super.key});

  final String type;

  @override
  State<_OneRankingPage> createState() => _OneRankingPageState();
}

class _OneRankingPageState
    extends MultiPageLoadingState<_OneRankingPage, Novel> {
  @override
  Widget buildContent(BuildContext context, final List<Novel> data) {
    return GridViewWithFixedItemHeight(
      itemCount: data.length,
      itemHeight: 164,
      minCrossAxisExtent: 400,
      builder: (context, index) {
        if (index == data.length - 1) {
          nextPage();
        }
        return NovelWidget(data[index]);
      },
    ).paddingHorizontal(8);
  }

  String? nextUrl;

  @override
  Future<Res<List<Novel>>> loadData(page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = await Network().getNovelRanking(widget.type, null);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}
