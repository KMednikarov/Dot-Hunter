import 'package:flutter/material.dart';

import 'analytics_service.dart';
import 'main_menu_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsService.init();
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Hunter',
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
        isDark: _themeMode == ThemeMode.dark,
        glowEnabled: _glowEnabled,
        powerupButtonsRight: _powerupButtonsRight,
        analyticsEnabled: _analyticsEnabled,
      ),
    );
  }
}
