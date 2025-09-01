import 'package:flutter/material.dart';

import 'game_page.dart';
import 'leaderboard_page.dart';
import 'settings_page.dart';
import 'shop_page.dart';

class MainMenuPage extends StatefulWidget {
  final bool isDark;
  final bool glowEnabled;
  final bool powerupButtonsRight;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onGlowChanged;
  final ValueChanged<bool> onPowerupPositionChanged;

  const MainMenuPage({
    super.key,
    required this.onThemeChanged,
    required this.onGlowChanged,
    required this.onPowerupPositionChanged,
    required this.isDark,
    required this.glowEnabled,
    required this.powerupButtonsRight,
  });

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle =
        ElevatedButton.styleFrom(minimumSize: const Size(200, 50));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dot ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final blur = 10 + (_controller.value * 10);
                    return Text(
                      'Hunter',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        shadows: [
                          Shadow(
                            blurRadius: blur,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GamePage(
                      glowEnabled: widget.glowEnabled,
                      powerupButtonsRight: widget.powerupButtonsRight,
                    ),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LeaderboardPage(),
                  ),
                );
              },
              child: const Text('Leaderboard'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ShopPage(),
                  ),
                );
              },
              child: const Text('Shop'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      isDark: widget.isDark,
                      glowEnabled: widget.glowEnabled,
                      powerupButtonsRight: widget.powerupButtonsRight,
                      onThemeChanged: widget.onThemeChanged,
                      onGlowChanged: widget.onGlowChanged,
                      onPowerupPositionChanged:
                          widget.onPowerupPositionChanged,
                    ),
                  ),
                );
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
