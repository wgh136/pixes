import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/components/title_bar.dart';
import 'package:pixes/foundation/log.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(title: "Logs"),
        Expanded(
          child: ListView.builder(
            reverse: true,
            controller: ScrollController(),
            itemCount: Log.logs.length,
            itemBuilder: (context, index){
              index =  Log.logs.length - index - 1;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: ColorScheme.of(context).surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 1),
                              child: Text(Log.logs[index].title),
                            ),
                          ),
                          const SizedBox(width: 3,),
                          Container(
                            decoration: BoxDecoration(
                              color: [
                                ColorScheme.of(context).error,
                                ColorScheme.of(context).errorContainer,
                                ColorScheme.of(context).primaryContainer
                              ][Log.logs[index].level.index],
                              borderRadius: const BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 1),
                              child: Text(
                                Log.logs[index].level.name,
                                style: TextStyle(color: Log.logs[index].level.index==0?Colors.white:Colors.black),),
                            ),
                          ),
                        ],
                      ),
                      Text(Log.logs[index].content),
                      Text(Log.logs[index].time.toString().replaceAll(RegExp(r"\.\w+"), "")),
                      Button(onPressed: (){
                        Clipboard.setData(ClipboardData(text: Log.logs[index].content));
                      }, child: const Text("复制")),
                      const Divider(),
                    ],
                  ),
                ),
              );
            },
          )
        )
      ],
    );
  }
}
