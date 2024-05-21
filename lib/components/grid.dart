import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pixes/foundation/app.dart';

class SliverGridViewWithFixedItemHeight extends StatelessWidget {
  const SliverGridViewWithFixedItemHeight(
      {required this.delegate,
      this.maxCrossAxisExtent = double.infinity,
      this.minCrossAxisExtent = 0,
      required this.itemHeight,
      super.key});

  final SliverChildDelegate delegate;

  final double maxCrossAxisExtent;

  final double minCrossAxisExtent;

  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: delegate,
      gridDelegate: SliverGridDelegateWithFixedHeight(
          itemHeight: itemHeight,
          maxCrossAxisExtent: maxCrossAxisExtent,
          minCrossAxisExtent: minCrossAxisExtent),
    ).sliverPadding(EdgeInsets.only(bottom: context.padding.bottom));
  }
}

class GridViewWithFixedItemHeight extends StatelessWidget {
  const GridViewWithFixedItemHeight(
      {required this.builder,
      required this.itemCount,
      this.maxCrossAxisExtent = double.infinity,
      this.minCrossAxisExtent = 0,
      required this.itemHeight,
      super.key});

  final Widget Function(BuildContext, int) builder;

  final int itemCount;

  final double maxCrossAxisExtent;

  final double minCrossAxisExtent;

  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: ((context, constraints) => GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedHeight(
                  itemHeight: itemHeight,
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  minCrossAxisExtent: minCrossAxisExtent),
              itemBuilder: builder,
              itemCount: itemCount,
              padding: EdgeInsets.only(bottom: context.padding.bottom),
            )));
  }
}

class SliverGridDelegateWithFixedHeight extends SliverGridDelegate {
  const SliverGridDelegateWithFixedHeight({
    this.maxCrossAxisExtent = double.infinity,
    this.minCrossAxisExtent = 0,
    required this.itemHeight,
  });

  final double maxCrossAxisExtent;

  final double minCrossAxisExtent;

  final double itemHeight;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    var crossItemsCount = calcCrossItemsCount(constraints.crossAxisExtent);
    return SliverGridRegularTileLayout(
        crossAxisCount: crossItemsCount,
        mainAxisStride: itemHeight,
        childMainAxisExtent: itemHeight,
        crossAxisStride: constraints.crossAxisExtent / crossItemsCount,
        childCrossAxisExtent: constraints.crossAxisExtent / crossItemsCount,
        reverseCrossAxis: false);
  }

  int calcCrossItemsCount(double width) {
    int count = 20;
    var itemWidth = width / 20;

    if(minCrossAxisExtent == 0) {
      count = 1;
      itemWidth = width;
      while(itemWidth > maxCrossAxisExtent) {
        count++;
        itemWidth = width / count;
      }
      return count;
    }

    while (
        !(itemWidth > minCrossAxisExtent && itemWidth < maxCrossAxisExtent)) {
      count--;
      itemWidth = width / count;
      if (count == 1) {
        return 1;
      }
    }
    return count;
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return oldDelegate is! SliverGridDelegateWithFixedHeight ||
        oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.minCrossAxisExtent != minCrossAxisExtent ||
        oldDelegate.itemHeight != itemHeight;
  }
}
