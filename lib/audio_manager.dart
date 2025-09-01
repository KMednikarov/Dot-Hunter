import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  AudioManager._internal();
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _enabled = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('sound') ?? true;
    if (_enabled) {
      playBackgroundMusic();
    }
  }

  bool get enabled => _enabled;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
    if (_enabled) {
      playBackgroundMusic();
    } else {
      try {
        await _bgmPlayer.stop();
      } catch (_) {}
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_enabled) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/background.mp3'));
    } catch (_) {}
  }

  Future<void> playTapSound() async {
    if (!_enabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/tap.mp3'));
    } catch (_) {}
  }

  Future<void> playAlertSound() async {
    if (!_enabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/alert.mp3'));
    } catch (_) {}
  }
}
