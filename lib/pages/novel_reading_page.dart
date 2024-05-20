import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/loading.dart';
import 'package:pixes/network/network.dart';

class NovelReadingPage extends StatefulWidget {
  const NovelReadingPage(this.novel, {super.key});

  final Novel novel;

  @override
  State<NovelReadingPage> createState() => _NovelReadingPageState();
}

class _NovelReadingPageState extends LoadingState<NovelReadingPage, String> {
  @override
  Widget buildContent(BuildContext context, String data) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SelectionArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.novel.title,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              const Divider(
                style: DividerThemeData(horizontalMargin: EdgeInsets.all(0)),
              ),
              const SizedBox(height: 12.0),
              Text(data,
                  style: const TextStyle(
                    fontSize: 16.0,
                    height: 1.6,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<Res<String>> loadData() {
    return Network().getNovelContent(widget.novel.id.toString());
  }
}
