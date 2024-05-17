import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/download.dart';
import 'package:pixes/utils/translation.dart';

import '../utils/io.dart';

class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> {
  @override
  void initState() {
    DownloadManager().registerUiUpdater(() => setState((){}));
    super.initState();
  }

  @override
  void dispose() {
    DownloadManager().removeUiUpdater();
    super.dispose();
  }

  Map<String, FlyoutController> controller = {};

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: CustomScrollView(
        slivers: [
          buildTop(),
          const SliverPadding(padding: EdgeInsets.only(top: 16)),
          buildContent()
        ],
      ),
    );
  }

  Widget buildTop() {
    int bytesPerSecond = DownloadManager().bytesPerSecond;

    bool paused = DownloadManager().paused;

    return SliverTitleBar(
      title: paused
        ? "Paused".tl
        :"${"Speed".tl}: ${bytesToText(bytesPerSecond)}/s",
      action: SplitButton(
        onInvoked: (){
          if(!paused) {
            DownloadManager().pause();
            setState(() {});
          } else {
            DownloadManager().resume();
            setState(() {});
          }
        },
        flyout: MenuFlyout(
          items: [
            MenuFlyoutItem(text: Text("Cancel All".tl), onPressed: (){
              var tasks = List.from(DownloadManager().tasks);
              DownloadManager().tasks.clear();
              for(var task in tasks) {
                task.cancel();
              }
              setState(() {});
            })
          ],
        ),
        child: Text(paused ? "Resume".tl : "Pause".tl)
            .toCenter().fixWidth(56).fixHeight(32),
      ),
    );
  }

  Widget buildContent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (context, index) {
            var task = DownloadManager().tasks[index];
            return buildItem(task);
          },
          childCount: DownloadManager().tasks.length
      ),
    ).sliverPaddingHorizontal(12);
  }

  Widget buildItem(DownloadingTask task) {
    controller[task.illust.id.toString()] ??= FlyoutController();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 96,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              height: double.infinity,
              width: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ColorScheme.of(context).outlineVariant, width: 0.6),
              ),
              child: Image(
                image: CachedImageProvider(task.illust.images.first.medium),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(task.illust.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(task.illust.author.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  if(task.error == null)
                    Text("${task.downloadedImages}/${task.totalImages} ${"Downloaded".tl}", style: const TextStyle(fontSize: 12, color: Colors.grey))
                  else
                    Text("Error: ${task.error!.replaceAll("\n", " ")}", style: TextStyle(fontSize: 12, color: ColorScheme.of(context).error), maxLines: 2,),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(task.error != null)
                  Button(
                    child: Text("Retry".tl).fixWidth(46),
                    onPressed: () {
                      task.retry();
                      setState(() {});
                    },
                  ),
                const SizedBox(height: 4),
                FlyoutTarget(
                  controller: controller[task.illust.id.toString()]!,
                  child: Button(
                      child: Text("Cancel".tl, style: TextStyle(color: ColorScheme.of(context).error),).fixWidth(46),
                      onPressed: (){
                        controller[task.illust.id.toString()]!.showFlyout(
                          navigatorKey: App.rootNavigatorKey.currentState,
                          builder: (context) {
                            return FlyoutContent(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Are you sure you want to cancel this download?'.tl,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Button(
                                    onPressed: () {
                                      Flyout.of(context).close();
                                      task.cancel();
                                      setState(() {});
                                    },
                                    child: Text('Yes'.tl),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
