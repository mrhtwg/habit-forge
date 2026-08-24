import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioService extends GetxService {
  static AudioService get to => Get.find();
  final _player = AudioPlayer();
  bool _enabled = true;

  Future<void> init() async {}

  Future<void> play(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {}
  }

  Future<void> playComplete() => play('sounds/task_complete.mp3');

  Future<void> playHpDamage() => play('sounds/hp_damage.mp3');
  Future<void> playLevelUp() => play('sounds/level_up.mp3');
  Future<void> playPurchase() => play('sounds/purchase.mp3');
  Future<void> playTap() => play('sounds/tap.mp3');
  void setEnabled(bool v) => _enabled = v;
}
