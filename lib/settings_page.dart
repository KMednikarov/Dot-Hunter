import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({super.key, required this.isDark, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SwitchListTile(
        title: const Text('Dark Theme'),
        value: _isDark,
        onChanged: (value) {
          setState(() {
            _isDark = value;
          });
          widget.onThemeChanged(value);
        },
      ),
    );
  }
}
