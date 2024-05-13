import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/illust_widget.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage(this.id, {super.key});

  final String id;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends LoadingState<UserInfoPage, UserDetails> {
  @override
  Widget buildContent(BuildContext context, UserDetails data) {
    return ScaffoldPage(
      content: CustomScrollView(
        slivers: [
          buildUser(),
          buildInformation(),
          SliverToBoxAdapter(child: buildHeader("Artworks"),),
          _UserArtworks(data.id.toString(), key: ValueKey(data.id),),
        ],
      ),
    );
  }

  Widget buildUser() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Image(
                image: CachedImageProvider(data!.avatar),
                width: 64,
                height: 64,
              ),
            ),),
          const SizedBox(height: 8),
          Text(data!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Follows: '.tl),
                TextSpan(text: '${data!.totalFollowUsers}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(String title) {
    return SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ).toAlign(Alignment.centerLeft)).paddingLeft(16).paddingVertical(4);
  }

  Widget buildInformation() {
    Widget buildItem({IconData? icon, required String title, required String? content, Widget? trailing}) {
      if(content == null || content.isEmpty) {
        return const SizedBox.shrink();
      }
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: icon == null ? null : Icon(icon, size: 20,),
          title: Text(title),
          subtitle: SelectableText(content),
          trailing: trailing,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          buildHeader("Infomation".tl),
          buildItem(icon: MdIcons.comment_outlined, title: "Comment".tl, content: data!.comment),
          buildItem(icon: MdIcons.cake_outlined, title: "Birthday".tl, content: data!.birth),
          buildItem(icon: MdIcons.location_city_outlined, title: "Region", content: data!.region),
          buildItem(icon: MdIcons.work_outline, title: "Job".tl, content: data!.job),
          buildItem(icon: MdIcons.person_2_outlined, title: "Gender".tl, content: data!.gender),
          const SizedBox(height: 8,),
          buildHeader("Social Network".tl),
          buildItem(title: "Webpage",
              content: data!.webpage,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!)
              )),
          buildItem(title: "Twitter",
              content: data!.twitterUrl,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18),
                  onPressed: () => launchUrlString(data!.twitterUrl!)
              )),
          buildItem(title: "pawoo",
              content: data!.pawooUrl,
              trailing: IconButton(
                  icon: const Icon(MdIcons.open_in_new, size: 18,),
                  onPressed: () => launchUrlString(data!.pawooUrl!)
              )),
        ],
      ),
    );
  }

  @override
  Future<Res<UserDetails>> loadData() {
    return Network().getUserDetails(widget.id);
  }
}

class _UserArtworks extends StatefulWidget {
  const _UserArtworks(this.uid, {super.key});

  final String uid;

  @override
  State<_UserArtworks> createState() => _UserArtworksState();
}

class _UserArtworksState extends MultiPageLoadingState<_UserArtworks, Illust> {
  @override
  Widget buildLoading(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(
        child: Center(
          child: ProgressRing(),
        ),
      ),
    );
  }

  @override
  Widget buildError(context, error) {
    return SliverToBoxAdapter(
      child: SizedBox(
        child: Center(
          child: Row(
            children: [
              const Icon(FluentIcons.info),
              const SizedBox(width: 4,),
              Text(error)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, final List<Illust> data) {
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if(index == data.length - 1){
            nextPage();
          }
          return IllustWidget(data[index]);
        },
        childCount: data.length,
      ),
    ).sliverPaddingHorizontal(8);
  }

  String? nextUrl;

  @override
  Future<Res<List<Illust>>> loadData(page) async{
    if(nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = nextUrl == null
        ? await Network().getUserIllusts(widget.uid)
        : await Network().getIllustsWithNextUrl(nextUrl!);
    if(!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}

