import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';

/// Simple shop page allowing the player to buy extra lives and power-ups.
/// Extra lives can only be purchased up to three times while power-ups have no
/// such limit and are bought in pairs. Purchases persist across sessions using
/// [SharedPreferences].
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _extraLives = 0;
  int _extraPowerups = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extraLives = prefs.getInt('extraLives') ?? 0;
      _extraPowerups = prefs.getInt('extraPowerups') ?? 0;
    });
  }

  Future<void> _buyLife() async {
    if (_extraLives >= 3) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extraLives++;
    });
    await prefs.setInt('extraLives', _extraLives);
    AnalyticsService.logPurchase('extra_life');
  }

  Future<void> _buyPowerup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extraPowerups += 2;
    });
    await prefs.setInt('extraPowerups', _extraPowerups);
    AnalyticsService.logPurchase('powerup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Extra Lives: $_extraLives/3'),
            ElevatedButton(
              onPressed: _extraLives >= 3 ? null : _buyLife,
              child: const Text('Buy +1 Life'),
            ),
            const SizedBox(height: 20),
            Text('Extra Powerups: $_extraPowerups'),
            ElevatedButton(
              onPressed: _buyPowerup,
              child: const Text('Buy +2 Power Ups'),
            ),
          ],
        ),
      ),
    );
  }
}

