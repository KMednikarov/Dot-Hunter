import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'audio_manager.dart';

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final bool glowEnabled;
  final bool powerupButtonsRight;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onGlowChanged;
  final ValueChanged<bool> onPowerupPositionChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    required this.glowEnabled,
    required this.onGlowChanged,
    required this.powerupButtonsRight,
    required this.onPowerupPositionChanged,
    required this.onLocaleChanged,
    required this.locale,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDark;
  late bool _glowEnabled;
  late bool _powerupButtonsRight;
  late Locale _selectedLocale;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _glowEnabled = widget.glowEnabled;
    _powerupButtonsRight = widget.powerupButtonsRight;
    _selectedLocale = widget.locale;
    _soundEnabled = AudioManager().enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkTheme),
            value: _isDark,
            onChanged: (value) {
              setState(() {
                _isDark = value;
              });
              widget.onThemeChanged(value);
            },
          ),
          SwitchListTile(
            title: const Text('Sound'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              AudioManager().setEnabled(value);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.pulsatingGlow),
            value: _glowEnabled,
            onChanged: (value) {
              setState(() {
                _glowEnabled = value;
              });
              widget.onGlowChanged(value);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.powerupButtonsRight),
            value: _powerupButtonsRight,
            onChanged: (value) {
              setState(() {
                _powerupButtonsRight = value;
              });
              widget.onPowerupPositionChanged(value);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<Locale>(
              value: _selectedLocale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('es'), child: Text('Español')),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  setState(() {
                    _selectedLocale = locale;
                  });
                  widget.onLocaleChanged(locale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
