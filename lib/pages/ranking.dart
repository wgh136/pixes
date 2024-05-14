import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/utils/translation.dart';

import '../components/illust_widget.dart';
import '../components/loading.dart';
import '../network/network.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String type = "day";

  /// mode: day, week, month, day_male, day_female, week_original, week_rookie, day_manga, week_manga, month_manga, day_r18_manga, day_r18
  static const types = {
    "day": "Daily",
    "week": "Weekly",
    "month": "Monthly",
    "day_male": "For male",
    "day_female": "For female",
    "week_original": "Originals",
    "week_rookie": "Rookies",
    "day_manga": "Daily Manga",
    "week_manga": "Weekly Manga",
    "month_manga": "Monthly Manga",
    "day_r18_manga": "R18",
  };

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          buildHeader(),
          Expanded(
            child: _OneRankingPage(type, key: Key(type),),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return SizedBox(
      child: Row(
        children: [
          Text("Ranking".tl, style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),),
          const Spacer(),
          DropDownButton(
            title: Text(types[type]!),
            items: types.entries.map((e) => MenuFlyoutItem(
              text: Text(e.value.tl),
              onPressed: () {
                setState(() {
                  type = e.key;
                });
              },
            )).toList(),
          )
        ],
      )
    ).padding(const EdgeInsets.symmetric(vertical: 8, horizontal: 16));
  }
}

class _OneRankingPage extends StatefulWidget {
  const _OneRankingPage(this.type, {super.key});

  final String type;

  @override
  State<_OneRankingPage> createState() => _OneRankingPageState();
}

class _OneRankingPageState extends MultiPageLoadingState<_OneRankingPage, Illust> {
  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return LayoutBuilder(builder: (context, constrains){
      return MasonryGridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          if(index == data.length - 1){
            nextPage();
          }
          return IllustWidget(data[index]);
        },
      );
    });
  }

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async{
    if(nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = await Network().getRanking(widget.type, nextUrl);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}


