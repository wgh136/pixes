import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/components/illust_widget.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

import '../components/grid.dart';
import '../components/segmented_button.dart';
import '../components/user_preview.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  var type = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTab(),
        Expanded(
          child: type == 0
            ? const _RecommendationArtworksPage()
            : const _RecommendationUsersPage(),
        )
      ],
    );
  }

  Widget buildTab() {
    return SegmentedButton<int>(
      options: [
        SegmentedButtonOption(0, "Artworks".tl),
        SegmentedButtonOption(1, "Users".tl),
      ],
      onPressed: (key) {
        if(key != type) {
          setState(() {
            type = key;
          });
        }
      },
      value: type,
    ).padding(const EdgeInsets.symmetric(vertical: 8, horizontal: 8));
  }
}


class _RecommendationArtworksPage extends StatefulWidget {
  const _RecommendationArtworksPage();

  @override
  State<_RecommendationArtworksPage> createState() => _RecommendationArtworksPageState();
}

class _RecommendationArtworksPageState extends MultiPageLoadingState<_RecommendationArtworksPage, Illust> {
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

class _RecommendationUsersPage extends StatefulWidget {
  const _RecommendationUsersPage();

  @override
  State<_RecommendationUsersPage> createState() => _RecommendationUsersPageState();
}

class _RecommendationUsersPageState extends MultiPageLoadingState<_RecommendationUsersPage, UserPreview> {
  @override
  Widget buildContent(BuildContext context, List<UserPreview> data) {
    return CustomScrollView(
      slivers: [
        SliverGridViewWithFixedItemHeight(
          delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if(index == data.length - 1){
                  nextPage();
                }
                return UserPreviewWidget(data[index]);
              },
              childCount: data.length
          ),
          maxCrossAxisExtent: 520,
          itemHeight: 114,
        ).sliverPaddingHorizontal(8)
      ],
    );
  }

  @override
  Future<Res<List<UserPreview>>> loadData(page) async{
    var res = await Network().getRecommendationUsers();
    return res;
  }
}
