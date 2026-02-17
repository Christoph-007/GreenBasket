import 'dart:async';
import 'package:flutter/foundation.dart';

/// General-purpose debouncer for UI callbacks (not for BLoC — use rxdart there).
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
