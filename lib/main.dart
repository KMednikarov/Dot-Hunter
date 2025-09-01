import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'analytics_service.dart';
import 'audio_manager.dart';
import 'main_menu_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsService.init();
  await AudioManager().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _glowEnabled = true;
  bool _powerupButtonsRight = true;
  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _analyticsEnabled = AnalyticsService.enabled;
  }
  Locale _locale = const Locale('en');

  void _updateTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _updateGlow(bool enabled) {
    setState(() {
      _glowEnabled = enabled;
    });
  }

  void _updatePowerupPosition(bool right) {
    setState(() {
      _powerupButtonsRight = right;
    });
  }

  void _updateAnalytics(bool enabled) {
    setState(() {
      _analyticsEnabled = enabled;
    });
    AnalyticsService.setEnabled(enabled);
  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: _themeMode,
      home: MainMenuPage(
        onThemeChanged: _updateTheme,
        onGlowChanged: _updateGlow,
        onPowerupPositionChanged: _updatePowerupPosition,
        onAnalyticsChanged: _updateAnalytics,
        onLocaleChanged: _updateLocale,
        locale: _locale,
        isDark: _themeMode == ThemeMode.dark,
        glowEnabled: _glowEnabled,
        powerupButtonsRight: _powerupButtonsRight,
        analyticsEnabled: _analyticsEnabled,
      ),
    );
  }
}
