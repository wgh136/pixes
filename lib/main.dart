import "package:fluent_ui/fluent_ui.dart";
import "package:flutter/services.dart";
import "package:pixes/appdata.dart";
import "package:pixes/components/message.dart";
import "package:pixes/foundation/app.dart";
import "package:pixes/foundation/log.dart";
import "package:pixes/network/app_dio.dart";
import "package:pixes/pages/main_page.dart";
import "package:pixes/utils/app_links.dart";
import "package:window_manager/window_manager.dart";
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    Log.error("Unhandled", "${details.exception}\n${details.stack}");
  };
  setSystemProxy();
  SystemTheme.fallbackColor = Colors.blue;
  await SystemTheme.accentColor.load();
  await App.init();
  await appdata.readData();
  handleLinks();
  SystemTheme.onChange.listen((event) {
    StateController.findOrNull(tag: "MyApp")?.update();
  });
  if (App.isDesktop) {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(500, 600));
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent),
      child: StateBuilder<SimpleController>(
          init: SimpleController(),
          tag: "MyApp",
          builder: (controller) {
            return FluentApp(
                navigatorKey: App.rootNavigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'pixes',
                theme: FluentThemeData(
                    brightness: Brightness.light,
                    fontFamily: App.isWindows ? 'font' : null,
                    accentColor: AccentColor.swatch({
                      'darkest': SystemTheme.accentColor.darkest,
                      'darker': SystemTheme.accentColor.darker,
                      'dark': SystemTheme.accentColor.dark,
                      'normal': SystemTheme.accentColor.accent,
                      'light': SystemTheme.accentColor.light,
                      'lighter': SystemTheme.accentColor.lighter,
                      'lightest': SystemTheme.accentColor.lightest,
                    })),
                darkTheme: FluentThemeData(
                    brightness: Brightness.dark,
                    fontFamily: App.isWindows ? 'font' : null,
                    accentColor: AccentColor.swatch({
                      'darkest': SystemTheme.accentColor.darkest,
                      'darker': SystemTheme.accentColor.darker,
                      'dark': SystemTheme.accentColor.dark,
                      'normal': SystemTheme.accentColor.accent,
                      'light': SystemTheme.accentColor.light,
                      'lighter': SystemTheme.accentColor.lighter,
                      'lightest': SystemTheme.accentColor.lightest,
                    })),
                home: const MainPage(),
                builder: (context, child) {
                  ErrorWidget.builder = (details) {
                    if (details.exception
                        .toString()
                        .contains("RenderFlex overflowed")) {
                      return const SizedBox.shrink();
                    }
                    Log.error("UI", "${details.exception}\n${details.stack}");
                    return Text(details.exception.toString());
                  };
                  if (child == null) {
                    throw "widget is null";
                  }

                  return OverlayWidget(child);
                });
          }),
    );
  }
}
