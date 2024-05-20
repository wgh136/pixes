import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/components/page_route.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/user_info_page.dart';
import 'package:pixes/utils/translation.dart';

import '../components/md.dart';
import '../components/message.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage(this.id, {this.isNovel = false, super.key});

  final String id;

  final bool isNovel;

  static void show(BuildContext context, String id, {bool isNovel = false}) {
    Navigator.of(context)
        .push(SideBarRoute(CommentsPage(id, isNovel: isNovel)));
  }

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends MultiPageLoadingState<CommentsPage, Comment> {
  bool isCommenting = false;

  @override
  Widget buildContent(BuildContext context, List<Comment> data) {
    return Stack(
      children: [
        Positioned.fill(child: buildBody(context, data)),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: buildBottom(context),
        )
      ],
    );
  }

  Widget buildBody(BuildContext context, List<Comment> data) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text("Comments".tl, style: const TextStyle(fontSize: 20))
                .paddingVertical(16)
                .paddingHorizontal(12);
          } else if (index == data.length + 1) {
            return const SizedBox(
              height: 64,
            );
          }
          index--;
          var date = data[index].date;
          var dateText = "${date.year}/${date.month}/${date.day}";
          return Card(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 38,
                      width: 38,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: ColoredBox(
                          color: ColorScheme.of(context).secondaryContainer,
                          child: GestureDetector(
                            onTap: () => context.to(
                                () => UserInfoPage(data[index].id.toString())),
                            child: AnimatedImage(
                              image: CachedImageProvider(data[index].avatar),
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index].name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          dateText,
                          style: TextStyle(
                              fontSize: 12,
                              color: ColorScheme.of(context).outline),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                if (data[index].comment.isNotEmpty)
                  Text(
                    data[index].comment,
                    style: const TextStyle(fontSize: 16),
                  ),
                if (data[index].stampUrl != null)
                  SizedBox(
                    height: 64,
                    width: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedImage(
                        image: CachedImageProvider(data[index].stampUrl!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
              ],
            ),
          );
        });
  }

  Widget buildBottom(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      backgroundColor:
          FluentTheme.of(context).micaBackgroundColor.withOpacity(0.96),
      child: SizedBox(
        height: 52,
        child: TextBox(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          placeholder: "Comment".tl,
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
          ),
          onSubmitted: (s) {
            showToast(context, message: "Sending".tl);
            if (isCommenting) return;
            setState(() {
              isCommenting = true;
            });
            if (widget.isNovel) {
              Network().commentNovel(widget.id, s).then((value) {
                if (value.error) {
                  context.showToast(message: "Network Error");
                  setState(() {
                    isCommenting = false;
                  });
                } else {
                  isCommenting = false;
                  nextUrl = null;
                  reset();
                }
              });
            } else {
              Network().comment(widget.id, s).then((value) {
                if (value.error) {
                  context.showToast(message: "Network Error");
                  setState(() {
                    isCommenting = false;
                  });
                } else {
                  isCommenting = false;
                  nextUrl = null;
                  reset();
                }
              });
            }
          },
        ).paddingVertical(8).paddingHorizontal(12),
      ).paddingBottom(context.padding.bottom + context.viewInsets.bottom),
    );
  }

  String? nextUrl;

  @override
  Future<Res<List<Comment>>> loadData(int page) async {
    if (nextUrl == "end") {
      return Res.error("No more data");
    }
    var res = widget.isNovel
        ? await Network().getNovelComments(widget.id, nextUrl)
        : await Network().getComments(widget.id, nextUrl);
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    return res;
  }
}
