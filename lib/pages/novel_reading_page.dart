import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/image_page.dart';
import 'package:pixes/utils/ext.dart';

class NovelReadingPage extends StatefulWidget {
  const NovelReadingPage(this.novel, {super.key});

  final Novel novel;

  @override
  State<NovelReadingPage> createState() => _NovelReadingPageState();
}

class _NovelReadingPageState extends LoadingState<NovelReadingPage, String> {
  @override
  Widget buildContent(BuildContext context, String data) {
    var content = buildList(context).toList();
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SelectionArea(
          child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 16.0, height: 1.6),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            return content[index];
          },
          itemCount: content.length,
        ),
      )),
    );
  }

  @override
  Future<Res<String>> loadData() {
    return Network().getNovelContent(widget.novel.id.toString());
  }

  Iterable<Widget> buildList(BuildContext context) sync* {
    yield Text(widget.novel.title,
        style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold));
    yield const SizedBox(height: 12.0);
    yield const Divider(
      style: DividerThemeData(horizontalMargin: EdgeInsets.all(0)),
    );
    yield const SizedBox(height: 12.0);

    var novelContent = data!.split('\n');
    for (var content in novelContent) {
      if (content.isEmpty) continue;
      if (content.startsWith('[uploadedimage:')) {
        var imageId = content.nums;
        yield GestureDetector(
          onTap: () {
            ImagePage.show(["novel:${widget.novel.id.toString()}/$imageId"]);
          },
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: AnimatedImage(
              image:
                  CachedNovelImageProvider(widget.novel.id.toString(), imageId),
              filterQuality: FilterQuality.medium,
              fit: BoxFit.contain,
              height: 300,
              width: double.infinity,
            ),
          ),
        );
      } else {
        yield Text(content);
      }
    }
  }
}
