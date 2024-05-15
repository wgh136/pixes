import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/components/segmented_button.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

import '../components/illust_widget.dart';
import '../components/loading.dart';

class BookMarkedArtworkPage extends StatefulWidget {
  const BookMarkedArtworkPage({super.key});

  @override
  State<BookMarkedArtworkPage> createState() => _BookMarkedArtworkPageState();
}

class _BookMarkedArtworkPageState extends State<BookMarkedArtworkPage>{
  String restrict = "public";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTab(),
        Expanded(
          child: _OneBookmarkedPage(restrict, key: Key(restrict),),
        )
      ],
    );
  }

  Widget buildTab() {
    return TitleBar(
      title: "Bookmarks".tl,
      action: SegmentedButton(
        options: [
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
      ),
    );
  }
}

class _OneBookmarkedPage extends StatefulWidget {
  const _OneBookmarkedPage(this.restrict, {super.key});

  final String restrict;

  @override
  State<_OneBookmarkedPage> createState() => _OneBookmarkedPageState();
}

class _OneBookmarkedPageState extends MultiPageLoadingState<_OneBookmarkedPage, Illust> {
  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return LayoutBuilder(builder: (context, constrains){
      return MasonryGridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8)
            + EdgeInsets.only(bottom: context.padding.bottom),
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
    var res = await Network().getBookmarkedIllusts(widget.restrict, nextUrl);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

