import 'package:flutter/material.dart';

import 'main_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
var kDebugMode = true;

void main() {
WidgetsFlutterBinding.ensureInitialized(); // <-- required

  // OPTIONAL: dev-only fresh run wipe
  resetApp();
  runApp(const MyApp());
}

Future<void> resetApp() async {
  if (kDebugMode) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // If you use Hive/SQLite, wipe them too:
    // await Hive.initFlutter();
    // await Hive.deleteFromDisk();

    // final dbPath = await getDatabasesPath();
    // await databaseFactory.deleteDatabase(p.join(dbPath, 'app.db'));
  }
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
        isDark: _themeMode == ThemeMode.dark,
        glowEnabled: _glowEnabled,
        powerupButtonsRight: _powerupButtonsRight,
      ),
    );
  }
}
