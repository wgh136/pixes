import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({required this.title, this.action, super.key});

  final String title;

  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const Spacer(),
          if(action != null)
            action!
        ],
      ).paddingHorizontal(16).paddingVertical(8),
    );
  }
}

class SliverTitleBar extends StatelessWidget {
  const SliverTitleBar({required this.title, this.action, super.key});

  final String title;

  final Widget? action;


  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        child: Row(
          children: [
            Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            const Spacer(),
            if(action != null)
              action!
          ],
        ).paddingHorizontal(16).paddingVertical(8),
      ),
    );
  }
}
