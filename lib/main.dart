import "dart:ui";

import "package:dynamic_color/dynamic_color.dart";
import "package:fluent_ui/fluent_ui.dart";
import "package:flutter/material.dart" as md;
import "package:flutter/services.dart";
import "package:flutter_acrylic/flutter_acrylic.dart" as flutter_acrylic;
import "package:pixes/appdata.dart";
import "package:pixes/components/keyboard.dart";
import "package:pixes/components/md.dart";
import "package:pixes/components/message.dart";
import "package:pixes/foundation/app.dart";
import "package:pixes/foundation/log.dart";
import "package:pixes/network/app_dio.dart";
import "package:pixes/pages/main_page.dart";
import "package:pixes/utils/app_links.dart";
import "package:pixes/utils/loop.dart";
import "package:pixes/utils/translation.dart";
import "package:pixes/utils/window.dart";
import "package:window_manager/window_manager.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    Log.error("Unhandled", "${details.exception}\n${details.stack}");
  };
  setSystemProxy();
  await App.init();
  await appdata.readData();
  await Translation.init();
  handleLinks();
  if (App.isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (App.isWindows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(500, 600));
      var placement = await WindowPlacement.loadFromFile();
      await placement.applyToWindow();
      await windowManager.show();
      Loop.register(WindowPlacement.loop);
    });
  }
  Loop.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return StateBuilder<SimpleController>(
        init: SimpleController(),
        tag: "MyApp",
        builder: (controller) {
          Brightness brightness =
              PlatformDispatcher.instance.platformBrightness;

          if (appdata.settings["theme"] == "Dark") {
            brightness = Brightness.dark;
          } else if (appdata.settings["theme"] == "Light") {
            brightness = Brightness.light;
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: brightness.opposite,
              systemNavigationBarIconBrightness: brightness.opposite,
            ),
            child: DynamicColorBuilder(
              builder: (light, dark) {
                final colorScheme =
                    (brightness == Brightness.light ? light : dark) ??
                        md.ColorScheme.fromSeed(
                            seedColor: Colors.blue, brightness: brightness);
                return FluentApp(
                    navigatorKey: App.rootNavigatorKey,
                    debugShowCheckedModeBanner: false,
                    title: 'pixes',
                    theme: FluentThemeData(
                        brightness: brightness,
                        fontFamily: App.isWindows ? '微软雅黑' : null,
                        accentColor: AccentColor.swatch({
                          'darkest': darken(colorScheme.primary, 30),
                          'darker': darken(colorScheme.primary, 20),
                          'dark': darken(colorScheme.primary, 10),
                          'normal': colorScheme.primary,
                          'light': lighten(colorScheme.primary, 10),
                          'lighter': lighten(colorScheme.primary, 20),
                          'lightest': lighten(colorScheme.primary, 30)
                        }),
                        focusTheme: const FocusThemeData(
                          primaryBorder: BorderSide.none,
                          secondaryBorder: BorderSide.none,
                        )),
                    home: const MainPage(),
                    builder: (context, child) {
                      ErrorWidget.builder = (details) {
                        if (details.exception
                            .toString()
                            .contains("RenderFlex overflowed")) {
                          return const SizedBox.shrink();
                        }
                        Log.error(
                            "UI", "${details.exception}\n${details.stack}");
                        return Text(details.exception.toString());
                      };
                      if (child == null) {
                        throw "widget is null";
                      }

                      Widget widget = MdTheme(
                        data: MdThemeData.from(
                            colorScheme: colorScheme, useMaterial3: true),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontFamily: App.isWindows ? 'font' : null,
                          ),
                          child: OverlayWidget(child),
                        ),
                      );

                      if (App.isWindows) {
                        if (App.windowsVersion == 11) {
                          flutter_acrylic.Window.setEffect(
                              effect: flutter_acrylic.WindowEffect.mica,
                              dark: false);
                          widget = NavigationPaneTheme(
                            data: const NavigationPaneThemeData(
                              backgroundColor: Colors.transparent,
                            ),
                            child: widget,
                          );
                        } else if (App.windowsVersion == 10) {
                          flutter_acrylic.Window.setEffect(
                              effect: flutter_acrylic.WindowEffect.acrylic,
                              dark: false);
                          widget = NavigationPaneTheme(
                            data: NavigationPaneThemeData(
                              backgroundColor: FluentTheme.of(context)
                                  .micaBackgroundColor
                                  .withOpacity(0.05),
                            ),
                            child: widget,
                          );
                        }
                      }

                      return KeyEventListener(child: widget);
                    });
              },
            ),
          );
        });
  }
}

/// from https://stackoverflow.com/a/60191441
Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

/// from https://stackoverflow.com/a/60191441
Color lighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}
