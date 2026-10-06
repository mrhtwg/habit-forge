import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';

class AudioService extends GetxService {
  static AudioService get to => Get.find();
  final _player = AudioPlayer();
  final _enabled = true.obs;

  bool get enabled => _enabled.value;

  @override
  void onInit() {
    super.onInit();
    _enabled.value = SpUtils.ins.getBool(SpKeys.soundEnabled) ?? true;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }

  Future<void> init() async {}

  Future<void> play(String assetPath) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {}
  }

  Future<void> playComplete() => play('sounds/task_complete.mp3');
  Future<void> playHpDamage() => play('sounds/hp_damage.mp3');
  Future<void> playLevelUp() => play('sounds/level_up.mp3');
  Future<void> playPurchase() => play('sounds/purchase.mp3');
  Future<void> playTap() => enabled ? SystemSound.play(SystemSoundType.click) : Future<void>.value();

  Future<void> playDestructiveWarning() => enabled ? SystemSound.play(SystemSoundType.alert) : Future<void>.value();

  Future<void> playSuccessFeedback() => enabled ? SystemSound.play(SystemSoundType.click) : Future<void>.value();

  void setEnabled(bool v) {
    _enabled.value = v;
    SpUtils.ins.putBool(SpKeys.soundEnabled, v);
  }
}
