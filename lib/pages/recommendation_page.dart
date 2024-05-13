import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/components/illust_widget.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/network/res.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends MultiPageLoadingState<RecommendationPage, Illust> {
  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return LayoutBuilder(builder: (context, constrains){
      return MasonryGridView.builder(
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

  @override
  Future<Res<List<Illust>>> loadData(page) {
    return Network().getRecommendedIllusts();
  }
}