import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/animated_image.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/image_provider.dart';
import 'package:pixes/network/models.dart';

import '../pages/illust_page.dart';

class IllustWidget extends StatelessWidget {
  const IllustWidget(this.illust, {super.key});

  final Illust illust;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final width = constrains.maxWidth;
      final height = illust.height * width / illust.width;
      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Card(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: (){
                context.to(() => IllustPage(illust));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: AnimatedImage(
                  image: CachedImageProvider(illust.images.first.medium),
                  fit: BoxFit.cover,
                  width: width-16.0,
                  height: height-16.0,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
