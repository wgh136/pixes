import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';

class AutoCompleteItem {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const AutoCompleteItem({
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

class AutoCompleteData {
  final List<AutoCompleteItem> items;
  final bool isLoading;

  const AutoCompleteData({
    this.items = const <AutoCompleteItem>[],
    this.isLoading = false,
  });
}

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.autoCompleteItems = const <AutoCompleteItem>[],
    this.isLoadingAutoCompleteItems = false,
    this.enableAutoComplete = true,
    this.textEditingController,
    this.placeholder,
    this.leading,
    this.trailing,
    this.foregroundDecoration,
    this.onChanged,
    this.onSubmitted,
    this.padding,
    this.focusNode,
    this.autoCompleteNoResultsText,
  });

  final List<AutoCompleteItem> autoCompleteItems;

  final bool isLoadingAutoCompleteItems;

  final bool enableAutoComplete;

  final TextEditingController? textEditingController;

  final String? placeholder;

  final Widget? leading;

  final Widget? trailing;

  final WidgetStatePropertyAll<BoxDecoration>? foregroundDecoration;

  final void Function(String)? onChanged;

  final void Function(String)? onSubmitted;

  final EdgeInsets? padding;

  final FocusNode? focusNode;

  final String? autoCompleteNoResultsText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> with TickerProviderStateMixin {
  late final ValueNotifier<AutoCompleteData> autoCompleteItems;

  late final FocusNode focusNode;

  final boxKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    autoCompleteItems = ValueNotifier(AutoCompleteData(
      items: widget.autoCompleteItems,
      isLoading: widget.isLoadingAutoCompleteItems,
    ));
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(onfocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    focusNode.removeListener(onfocusChange);
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    if (widget.autoCompleteItems != oldWidget.autoCompleteItems ||
        widget.isLoadingAutoCompleteItems !=
            oldWidget.isLoadingAutoCompleteItems) {
      Future.microtask(() {
        autoCompleteItems.value = AutoCompleteData(
          items: widget.autoCompleteItems,
          isLoading: widget.isLoadingAutoCompleteItems,
        );
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void onfocusChange() {
    if (focusNode.hasFocus && widget.enableAutoComplete) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final overlay = Overlay.of(context);
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: overlay.context.findRenderObject(),
      );

      if (_overlayEntry != null) {
        _removeOverlayWithAnimation();
      }

      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOut,
      ));

      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            left: position.dx,
            width: box.size.width,
            top: position.dy + box.size.height,
            child: _AnimatedOverlayWrapper(
              animation: _fadeAnimation!,
              child: _AutoCompleteOverlay(
                data: autoCompleteItems,
                noResultsText: widget.autoCompleteNoResultsText,
              ),
            ),
          );
        },
      );

      overlay.insert(_overlayEntry!);
      _animationController!.forward();
    } else {
      _removeOverlayWithAnimation();
    }
  }

  void _removeOverlayWithAnimation() {
    if (_overlayEntry != null && _animationController != null) {
      _animationController!.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _animationController?.dispose();
        _animationController = null;
        _fadeAnimation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextBox(
      controller: widget.textEditingController,
      key: boxKey,
      focusNode: focusNode,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      placeholder: widget.placeholder,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      foregroundDecoration: widget.foregroundDecoration,
      prefix: widget.leading,
      suffix: widget.trailing,
    );
  }
}

class _AutoCompleteOverlay extends StatefulWidget {
  const _AutoCompleteOverlay({required this.data, this.noResultsText});

  final ValueNotifier<AutoCompleteData> data;

  final String? noResultsText;

  @override
  State<_AutoCompleteOverlay> createState() => _AutoCompleteOverlayState();
}

class _AutoCompleteOverlayState extends State<_AutoCompleteOverlay> {
  late final notifier = widget.data;

  var items = <AutoCompleteItem>[];

  var isLoading = false;

  @override
  void initState() {
    items = notifier.value.items;
    isLoading = notifier.value.isLoading;
    notifier.addListener(onItemsChanged);
    super.initState();
  }

  @override
  void dispose() {
    notifier.removeListener(onItemsChanged);
    super.dispose();
  }

  void onItemsChanged() {
    setState(() {
      items = notifier.value.items;
      isLoading = notifier.value.isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    var items = List<AutoCompleteItem>.from(this.items);

    Widget? content;

    if (isLoading) {
      content = SizedBox(
        height: 44,
        child: Center(
          child: ProgressRing(
            activeColor: FluentTheme.of(context).accentColor,
            strokeWidth: 2,
          ).fixWidth(24).fixHeight(24),
        ),
      );
    } else if (items.isEmpty) {
      content = ListTile(
        title: Text(widget.noResultsText ?? 'No results found'),
        onPressed: () {},
      );
    } else {
      if (items.length > 8) {
        items = items.sublist(0, 8);
      }
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return ListTile(
            title: Text(item.title),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            onPressed: item.onTap,
          );
        }).toList(),
      );
    }

    return Card(
      backgroundColor: FluentTheme.of(context).micaBackgroundColor,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 160),
        child: content,
      ),
    );
  }
}

class _AnimatedOverlayWrapper extends StatelessWidget {
  const _AnimatedOverlayWrapper({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.scale(
            scale: 0.9 + (0.1 * animation.value),
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
