import 'package:flutter/material.dart';

class TriggerNotifierContoller {
  ValueNotifier<bool> isUpdateTriggerNotifier = ValueNotifier(false);

  void triggerUpdate() {
    isUpdateTriggerNotifier.value = !isUpdateTriggerNotifier.value;
    print("triggerUpdateTrue");
    print(isUpdateTriggerNotifier.value );
  }
}