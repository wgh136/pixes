import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/network/res.dart';
import 'package:pixes/utils/translation.dart';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: Image(
              image: CachedImageProvider(data.avatar),
              width: 64,
              height: 64,
            ),
          ),
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
        ],
      ),
    );
  }

  @override
  Future<Res<UserDetails>> loadData() {
    return Network().getUserDetails(widget.id);
  }

}
