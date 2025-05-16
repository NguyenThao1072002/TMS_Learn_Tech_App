import 'package:flutter/widgets.dart';

class LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback? onResume;
  final VoidCallback? onPause;

  LifecycleObserver({this.onResume, this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && onResume != null) {
      onResume!();
    } else if (state == AppLifecycleState.paused && onPause != null) {
      onPause!();
    }
  }
}
