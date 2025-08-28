import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final bool glowEnabled;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onGlowChanged;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    required this.glowEnabled,
    required this.onGlowChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDark;
  late bool _glowEnabled;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _glowEnabled = widget.glowEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: _isDark,
            onChanged: (value) {
              setState(() {
                _isDark = value;
              });
              widget.onThemeChanged(value);
            },
          ),
          SwitchListTile(
            title: const Text('Pulsating Glow'),
            value: _glowEnabled,
            onChanged: (value) {
              setState(() {
                _glowEnabled = value;
              });
              widget.onGlowChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
