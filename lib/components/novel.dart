import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/pages/novel_page.dart';

class NovelWidget extends StatefulWidget {
  const NovelWidget(this.novel, {super.key});

  final Novel novel;

  @override
  State<NovelWidget> createState() => _NovelWidgetState();
}

class _NovelWidgetState extends State<NovelWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: () {
          context.to(() => NovelPage(widget.novel));
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 96,
              height: double.infinity,
              decoration: BoxDecoration(
                color: ColorScheme.of(context).secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedImage(
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                width: double.infinity,
                height: double.infinity,
                image: CachedImageProvider(widget.novel.image),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.novel.title,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: Text(
                      widget.novel.caption.trim().replaceAll('<br />', '\n'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.novel.author.name,
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
