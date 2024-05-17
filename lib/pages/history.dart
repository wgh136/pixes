import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

import '../components/illust_widget.dart';
import 'illust_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends MultiPageLoadingState<HistoryPage, Illust> {
  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return Column(
      children: [
        TitleBar(title: "History".tl),
        Expanded(
          child: LayoutBuilder(builder: (context, constrains){
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
                return IllustWidget(data[index], onTap: () {
                  context.to(() => IllustGalleryPage(
                      illusts: data,
                      initialPage: index,
                  ));
                });
              },
            );
          }),
        )
      ],
    );
  }

  @override
  Future<Res<List<Illust>>> loadData(page) {
    if(appdata.account?.user.isPremium != true) {
      return Future.value(Res.error("Premium Required".tl));
    }
    return Network().getHistory(page);
  }
}
