import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/message.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/download.dart';
import 'package:pixes/utils/translation.dart';

import '../network/network.dart';

class BatchDownloadButton extends StatelessWidget {
  const BatchDownloadButton({super.key, required this.request});

  final Future<Res<List<Illust>>> Function() request;

  @override
  Widget build(BuildContext context) {
    return Button(
      child: const Icon(MdIcons.download, size: 20,),
      onPressed: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            useRootNavigator: false,
            builder: (context) => _DownloadDialog(request));
      },
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog(this.request);

  final Future<Res<List<Illust>>> Function() request;

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  int maxCount = 30;

  bool loading = false;

  bool cancel = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text("Batch download".tl),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${"Maximum number of downloads".tl}:'),
            const SizedBox(height: 16,),
            SizedBox(
              height: 42,
              width: 196,
              child: NumberBox(
                value: maxCount,
                onChanged: (value) {
                  if(!loading) {
                    setState(() => maxCount = value ?? maxCount);
                  }
                },
                allowExpressions: true,
                mode: SpinButtonPlacementMode.inline,
                smallChange: 10,
                largeChange: 30,
                clearButton: false,
              ),
            )
          ],
        ).paddingVertical(8),
      ),
      actions: [
        Button(child: Text("Cancel".tl), onPressed: () {
          cancel = true;
          context.pop();
        }),
        if(!loading)
          FilledButton(onPressed: load, child: Text("Continue".tl))
        else
          FilledButton(onPressed: (){}, child: const SizedBox(
            height: 20,
            width: 64,
            child: Center(
              child: SizedBox.square(
                dimension: 18,
                child: ProgressRing(
                  strokeWidth: 1.6,
                ),
              ),
            ),
          ))
      ],
    );
  }

  void load() async{
    setState(() {
      loading = true;
    });

    var request = widget.request();

    List<Illust> all = [];
    String? nextUrl;
    int retryCount = 0;
    while(nextUrl != "end" && all.length < maxCount) {
      if(nextUrl != null) {
        request = Network().getIllustsWithNextUrl(nextUrl);
      }
      var res = await request;
      if(cancel || !mounted) {
        return;
      }
      if(res.error) {
        retryCount++;
        if(retryCount > 3) {
          setState(() {
            loading = false;
          });
          showToast(context, message: "Error".tl);
          return;
        }
        await Future.delayed(Duration(seconds: 1 << retryCount));
        continue;
      }
      all.addAll(res.data);
      nextUrl = res.subData ?? "end";
    }
    int i = 0;
    for(var illust in all) {
      if(i > maxCount)  return;
      DownloadManager().addDownloadingTask(illust);
      i++;
    }
    context.pop();
  }
}

