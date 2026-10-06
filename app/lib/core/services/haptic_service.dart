import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';

class HapticService extends GetxService {
  static HapticService get to => Get.find();
  final _enabledState = true.obs;
  bool get _enabled => _enabledState.value;

  @override
  void onInit() {
    super.onInit();
    _enabledState.value = SpUtils.ins.getBool(SpKeys.hapticEnabled) ?? true;
  }

  void error() {
    if (_enabled) {
      HapticFeedback.heavyImpact();
      HapticFeedback.heavyImpact();
    }
  }

  void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  void setEnabled(bool v) {
    _enabledState.value = v;
    SpUtils.ins.putBool(SpKeys.hapticEnabled, v);
  }

  bool get enabled => _enabled;

  void success() {
    if (_enabled) {
      HapticFeedback.mediumImpact();
      HapticFeedback.lightImpact();
    }
  }
}
