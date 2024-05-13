import "dart:async";

import "package:fluent_ui/fluent_ui.dart";
import "package:pixes/appdata.dart";
import "package:pixes/components/color_scheme.dart";
import "package:pixes/components/md.dart";
import "package:pixes/foundation/app.dart";
import "package:pixes/network/network.dart";
import "package:pixes/pages/bookmarks.dart";
import "package:pixes/pages/explore_page.dart";
import "package:pixes/pages/recommendation_page.dart";
import "package:pixes/pages/login_page.dart";
import "package:pixes/pages/search_page.dart";
import "package:pixes/pages/settings_page.dart";
import "package:pixes/pages/user_info_page.dart";
import "package:pixes/utils/mouse_listener.dart";
import "package:pixes/utils/translation.dart";
import "package:window_manager/window_manager.dart";

import "../components/page_route.dart";

const _kAppBarHeight = 36.0;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WindowListener {
  final navigatorKey = GlobalKey<NavigatorState>();

  int index = 2;

  int windowButtonKey = 0;

  @override
  void initState() {
    windowManager.addListener(this);
    listenMouseSideButtonToBack(navigatorKey);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      windowButtonKey++;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      windowButtonKey++;
    });
  }

  bool get isLogin => Network().token != null;

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      return NavigationView(
        appBar: buildAppBar(context, navigatorKey),
        content: LoginPage(() => setState(() {})),
      );
    }
    return ColorScheme(
        brightness: FluentTheme.of(context).brightness,
        child: NavigationView(
            appBar: buildAppBar(context, navigatorKey),
            pane: NavigationPane(
              selected: index,
              onChanged: (value) {
                setState(() {
                  index = value;
                });
                navigate(value);
              },
              items: [
                UserPane(),
                PaneItem(
                  icon: const Icon(MdIcons.search, size: 20,),
                  title: Text('Search'.tl),
                  body: const SizedBox.shrink(),
                ),
                PaneItemHeader(header: Text("Artwork".tl).paddingVertical(4).paddingLeft(8)),
                PaneItem(
                  icon: const Icon(MdIcons.star_border, size: 20,),
                  title: Text('Recommendations'.tl),
                  body: const SizedBox.shrink(),
                ),
                PaneItem(
                  icon: const Icon(MdIcons.bookmark_outline, size: 20),
                  title: Text('Bookmarks'.tl),
                  body: const SizedBox.shrink(),
                ),
                PaneItemSeparator(),
                PaneItem(
                  icon: const Icon(MdIcons.explore_outlined, size: 20),
                  title: Text('Explore'.tl),
                  body: const SizedBox.shrink(),
                ),
              ],
              footerItems: [
                PaneItem(
                  icon: const Icon(MdIcons.settings_outlined, size: 20),
                  title: Text('Settings'.tl),
                  body: const SizedBox.shrink(),
                ),
              ],
            ),
            paneBodyBuilder: (pane, child) => Navigator(
                  key: navigatorKey,
                  onGenerateRoute: (settings) => AppPageRoute(
                      builder: (context) => const RecommendationPage()),
                )));
  }

  static final pageBuilders = [
    () => UserInfoPage(appdata.account!.user.id),
    () => const SearchPage(),
    () => const RecommendationPage(),
    () => const BookMarkedArtworkPage(),
    () => const ExplorePage(),
    () => const SettingsPage(),
  ];

  void navigate(int index) {
    var page = pageBuilders.elementAtOrNull(index) ??
        () => Center(
              child: Text("Invalid Page: $index"),
            );
    navigatorKey.currentState!.pushAndRemoveUntil(
        AppPageRoute(builder: (context) => page()), (route) => false);
  }

  NavigationAppBar buildAppBar(
      BuildContext context, GlobalKey<NavigatorState> navigatorKey) {
    return NavigationAppBar(
      automaticallyImplyLeading: false,
      height: _kAppBarHeight,
      title: () {
        if (!App.isDesktop) {
          return const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text("pixes"),
          );
        }
        return const DragToMoveArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Pixes",
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        );
      }(),
      leading: _BackButton(navigatorKey),
      actions: WindowButtons(
        key: ValueKey(windowButtonKey),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  GlobalKey<NavigatorState> get navigatorKey => widget.navigatorKey;

  bool enabled = false;

  Timer? timer;

  @override
  void initState() {
    enabled = navigatorKey.currentState?.canPop() == true;
    loop();
    super.initState();
  }

  void loop() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if(!mounted) {
        timer.cancel();
      } else {
        bool enabled = navigatorKey.currentState?.canPop() == true;
        if(enabled != this.enabled) {
          setState(() {
            this.enabled = enabled;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }
    }

    return NavigationPaneTheme(
      data: NavigationPaneTheme.of(context).merge(NavigationPaneThemeData(
        unselectedIconColor: ButtonState.resolveWith((states) {
          if (states.isDisabled) {
            return ButtonThemeData.buttonColor(context, states);
          }
          return ButtonThemeData.uncheckedInputColor(
            FluentTheme.of(context),
            states,
          ).basedOnLuminance();
        }),
      )),
      child: Builder(
        builder: (context) => PaneItem(
          icon: const Center(child: Icon(FluentIcons.back, size: 12.0)),
          title: const Text("Back"),
          body: const SizedBox.shrink(),
          enabled: enabled,
        ).build(
          context,
          false,
          onPressed,
          displayMode: PaneDisplayMode.compact,
        ).paddingTop(2),
      ),
    );
  }
}


class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);
    final color = theme.iconTheme.color ?? Colors.black;
    final hoverColor = theme.inactiveBackgroundColor;

    return SizedBox(
      width: 138,
      height: _kAppBarHeight,
      child: Row(
        children: [
          WindowButton(
            icon: MinimizeIcon(color: color),
            hoverColor: hoverColor,
            onPressed: () async {
              bool isMinimized = await windowManager.isMinimized();
              if (isMinimized) {
                windowManager.restore();
              } else {
                windowManager.minimize();
              }
            },
          ),
          FutureBuilder<bool>(
            future: windowManager.isMaximized(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == true) {
                return WindowButton(
                  icon: RestoreIcon(
                    color: color,
                  ),
                  hoverColor: hoverColor,
                  onPressed: () {
                    windowManager.unmaximize();
                  },
                );
              }
              return WindowButton(
                icon: MaximizeIcon(
                  color: color,
                ),
                hoverColor: hoverColor,
                onPressed: () {
                  windowManager.maximize();
                },
              );
            },
          ),
          WindowButton(
            icon: CloseIcon(
              color: color,
            ),
            hoverIcon: CloseIcon(
              color: theme.brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
            ),
            hoverColor: Colors.red,
            onPressed: () {
              windowManager.close();
            },
          ),
        ],
      ),
    );
  }
}

class WindowButton extends StatefulWidget {
  const WindowButton(
      {required this.icon,
      required this.onPressed,
      required this.hoverColor,
      this.hoverIcon,
      super.key});

  final Widget icon;

  final void Function() onPressed;

  final Color hoverColor;

  final Widget? hoverIcon;

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        isHovering = true;
      }),
      onExit: (event) => setState(() {
        isHovering = false;
      }),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: double.infinity,
          decoration:
              BoxDecoration(color: isHovering ? widget.hoverColor : null),
          child: isHovering ? widget.hoverIcon ?? widget.icon : widget.icon,
        ),
      ),
    );
  }
}

class UserPane extends PaneItem {
  UserPane() : super(icon: const SizedBox(), body: const SizedBox());

  @override
  Widget build(BuildContext context, bool selected, VoidCallback? onPressed,
      {PaneDisplayMode? displayMode,
      bool showTextOnTop = true,
      int? itemIndex,
      bool? autofocus}) {
    final maybeBody = NavigationView.maybeOf(context);
    var mode = displayMode ?? maybeBody?.displayMode ?? PaneDisplayMode.minimal;

    if (maybeBody?.compactOverlayOpen == true) {
      mode = PaneDisplayMode.open;
    }

    Widget body = () {
      switch (mode) {
        case PaneDisplayMode.minimal:
        case PaneDisplayMode.open:
          return LayoutBuilder(builder: (context, constrains) {
            if (constrains.maxHeight < 72 || constrains.maxWidth < 120) {
              return const SizedBox();
            }
            return Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: Image(
                        height: 48,
                        width: 48,
                        image: NetworkImage(appdata.account!.user.profile),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  if (constrains.maxWidth > 90)
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appdata.account!.user.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                appdata.account!.user.email,
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            );
          });
        case PaneDisplayMode.compact:
        case PaneDisplayMode.top:
          return LayoutBuilder(builder: (context, constrains) {
            if (constrains.maxHeight < 48 || constrains.maxWidth < 32) {
              return const SizedBox();
            }
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image(
                  height: 30,
                  width: 30,
                  image: NetworkImage(appdata.account!.user.profile),
                  fit: BoxFit.fill,
                ),
              ).paddingAll(4),
            );
          });
        default:
          throw "Invalid Display mode";
      }
    }();

    var button = HoverButton(
      builder: (context, states) {
        final theme = NavigationPaneTheme.of(context);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: () {
              final tileColor = this.tileColor ??
                  theme.tileColor ??
                  kDefaultPaneItemColor(context, mode == PaneDisplayMode.top);
              final newStates = states.toSet()..remove(ButtonStates.disabled);
              if (selected && selectedTileColor != null) {
                return selectedTileColor!.resolve(newStates);
              }
              return tileColor.resolve(
                selected
                    ? {
                        states.isHovering
                            ? ButtonStates.pressing
                            : ButtonStates.hovering,
                      }
                    : newStates,
              );
            }(),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: false,
            child: body,
          ),
        );
      },
      onPressed: onPressed,
    );

    return Padding(
      key: key,
      padding: const EdgeInsetsDirectional.only(bottom: 4.0),
      child: button,
    );
  }
}

/// Close
class CloseIcon extends StatelessWidget {
  final Color color;
  const CloseIcon({super.key, required this.color});
  @override
  Widget build(BuildContext context) => _AlignedPaint(_ClosePainter(color));
}

class _ClosePainter extends _IconPainter {
  _ClosePainter(super.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color, true);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), p);
  }
}

/// Maximize
class MaximizeIcon extends StatelessWidget {
  final Color color;
  const MaximizeIcon({super.key, required this.color});
  @override
  Widget build(BuildContext context) => _AlignedPaint(_MaximizePainter(color));
}

class _MaximizePainter extends _IconPainter {
  _MaximizePainter(super.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width - 1, size.height - 1), p);
  }
}

/// Restore
class RestoreIcon extends StatelessWidget {
  final Color color;
  const RestoreIcon({
    super.key,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => _AlignedPaint(_RestorePainter(color));
}

class _RestorePainter extends _IconPainter {
  _RestorePainter(super.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawRect(Rect.fromLTRB(0, 2, size.width - 2, size.height), p);
    canvas.drawLine(const Offset(2, 2), const Offset(2, 0), p);
    canvas.drawLine(const Offset(2, 0), Offset(size.width, 0), p);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height - 2), p);
    canvas.drawLine(Offset(size.width, size.height - 2),
        Offset(size.width - 2, size.height - 2), p);
  }
}

/// Minimize
class MinimizeIcon extends StatelessWidget {
  final Color color;
  const MinimizeIcon({super.key, required this.color});
  @override
  Widget build(BuildContext context) => _AlignedPaint(_MinimizePainter(color));
}

class _MinimizePainter extends _IconPainter {
  _MinimizePainter(super.color);
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = getPaint(color);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }
}

/// Helpers
abstract class _IconPainter extends CustomPainter {
  _IconPainter(this.color);
  final Color color;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlignedPaint extends StatelessWidget {
  const _AlignedPaint(this.painter);
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: CustomPaint(size: const Size(10, 10), painter: painter));
  }
}

Paint getPaint(Color color, [bool isAntiAlias = false]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..isAntiAlias = isAntiAlias
  ..strokeWidth = 1;
