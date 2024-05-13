import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/segmented_button.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';

import '../components/grid.dart';
import '../components/user_preview.dart';

class FollowingUsersPage extends StatefulWidget {
  const FollowingUsersPage(this.uid, {super.key});

  final String uid;

  @override
  State<FollowingUsersPage> createState() => _FollowingUsersPageState();
}

class _FollowingUsersPageState extends MultiPageLoadingState<FollowingUsersPage, UserPreview> {
  String type = "public";

  @override
  Widget buildContent(BuildContext context, final List<UserPreview> data) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Text("Following".tl,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                  .paddingVertical(12).paddingLeft(16),
              const Spacer(),
              if(widget.uid == appdata.account?.user.id)
                SegmentedButton(
                  value: type,
                  options: [
                    SegmentedButtonOption("public", "Public".tl),
                    SegmentedButtonOption("private", "Private".tl),
                  ],
                  onPressed: (s) {
                    type = s;
                    reset();
                  },
                ),
              const SizedBox(width: 16,)
            ],
          ),
        ),
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

  String? nextUrl;

  @override
  Future<Res<List<UserPreview>>> loadData(page) async{
    if(nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = await Network().getFollowing(widget.uid, type, nextUrl);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}
