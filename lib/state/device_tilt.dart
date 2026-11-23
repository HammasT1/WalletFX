import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// How far the phone has been tilted away from the way it is being held,
/// from -1 to 1 on each axis.
///
/// It reads the accelerometer, so it measures the phone's angle against
/// gravity. The resting angle slowly follows the phone, so holding it at any
/// angle settles back to zero and only fresh movement registers.
///
/// On platforms without a motion sensor, [tilt] simply stays at zero.
class DeviceTilt {
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);

  StreamSubscription<AccelerometerEvent>? _subscription;
  Offset? _resting;
  Offset _smoothed = Offset.zero;

  /// Tilting the phone by this much gravity (about 20°) moves the value
  /// all the way to 1.
  static const double _fullTilt = 0.35;

  static bool get isSupported {
    if (kIsWeb) {
      return true;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  void start() {
    if (!isSupported || _subscription != null) {
      return;
    }
    try {
      _subscription =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          ).listen(
            _onReading,
            // No sensor on this device: leave the foil to the touch tilt.
            onError: (Object _) => stop(),
            cancelOnError: true,
          );
    } catch (_) {
      _subscription = null;
    }
  }

  void _onReading(AccelerometerEvent event) {
    // Gravity along the screen's width and height, as a fraction of 1 g.
    final gravity = Offset(event.x / 9.81, event.y / 9.81);
    final resting = Offset.lerp(_resting ?? gravity, gravity, 0.012)!;
    _resting = resting;
    _smoothed = Offset.lerp(_smoothed, gravity - resting, 0.18)!;

    final next = Offset(
      (-_smoothed.dx / _fullTilt).clamp(-1.0, 1.0),
      (_smoothed.dy / _fullTilt).clamp(-1.0, 1.0),
    );
    // Skip changes too small to see, to save repaints.
    if ((next - tilt.value).distance > 0.004) {
      tilt.value = next;
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _resting = null;
    _smoothed = Offset.zero;
    tilt.value = Offset.zero;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    tilt.dispose();
  }
}
