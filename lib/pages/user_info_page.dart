import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/color_scheme.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage(this.id, {super.key});

  final String id;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends LoadingState<UserInfoPage, UserDetails> {
  @override
  Widget buildContent(BuildContext context, UserDetails data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Image(
                image: CachedImageProvider(data.avatar),
                width: 64,
                height: 64,
              ),
            ),),
          const SizedBox(height: 8),
          Text(data.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Follows: '.tl),
                TextSpan(text: '${data.totalFollowUsers}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8,),
          buildHeader("Infomation".tl),
          buildItem(icon: MdIcons.comment_outlined, title: "Comment".tl, content: data.comment),
          buildItem(icon: MdIcons.cake_outlined, title: "Birthday".tl, content: data.birth),
          buildItem(icon: MdIcons.location_city_outlined, title: "Region", content: data.region),
          buildItem(icon: MdIcons.work_outline, title: "Job".tl, content: data.job),
          buildItem(icon: MdIcons.person_2_outlined, title: "Gender".tl, content: data.gender),
          const SizedBox(height: 8,),
          buildHeader("Social Network".tl),
          buildItem(title: "Webpage", content: data.webpage, onTap: () => launchUrlString(data.webpage!)),
          buildItem(title: "Twitter", content: data.twitterUrl, onTap: () => launchUrlString(data.twitterUrl!)),
          buildItem(title: "pawoo", content: data.pawooUrl, onTap: () => launchUrlString(data.pawooUrl!))
        ],
      ),
    );
  }

  Widget buildItem({IconData? icon, required String title, required String? content, VoidCallback? onTap}) {
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
        onPressed: onTap,
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

  @override
  Future<Res<UserDetails>> loadData() {
    return Network().getUserDetails(widget.id);
  }

}
