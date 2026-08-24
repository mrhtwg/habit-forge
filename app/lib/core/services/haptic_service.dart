import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HapticService extends GetxService {
  static HapticService get to => Get.find();
  bool _enabled = true;

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

  void setEnabled(bool v) => _enabled = v;

  void success() {
    if (_enabled) {
      HapticFeedback.mediumImpact();
      HapticFeedback.lightImpact();
    }
  }
}
