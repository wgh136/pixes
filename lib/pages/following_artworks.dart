import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/utils/translation.dart';

import '../components/illust_widget.dart';
import '../components/loading.dart';
import '../components/segmented_button.dart';
import '../network/network.dart';

class FollowingArtworksPage extends StatefulWidget {
  const FollowingArtworksPage({super.key});

  @override
  State<FollowingArtworksPage> createState() => _FollowingArtworksPageState();
}

class _FollowingArtworksPageState extends State<FollowingArtworksPage> {
  String restrict = "all";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTab(),
        Expanded(
          child: _OneFollowingPage(restrict, key: Key(restrict),),
        )
      ],
    );
  }

  Widget buildTab() {
    return SegmentedButton(
      options: [
        SegmentedButtonOption("all", "All".tl),
        SegmentedButtonOption("public", "Public".tl),
        SegmentedButtonOption("private", "Private".tl),
      ],
      onPressed: (key) {
        if(key != restrict) {
          setState(() {
            restrict = key;
          });
        }
      },
      value: restrict,
    ).padding(const EdgeInsets.symmetric(vertical: 8, horizontal: 8));
  }
}

class _OneFollowingPage extends StatefulWidget {
  const _OneFollowingPage(this.restrict, {super.key});

  final String restrict;

  @override
  State<_OneFollowingPage> createState() => _OneFollowingPageState();
}

class _OneFollowingPageState extends MultiPageLoadingState<_OneFollowingPage, Illust> {
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

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async{
    if(nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = await Network().getFollowingArtworks(widget.restrict, nextUrl);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

