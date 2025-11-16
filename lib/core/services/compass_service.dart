import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// خدمة البوصلة باستخدام sensors_plus
/// Compass service using sensors_plus magnetometer
class CompassService {
  static CompassService? _instance;
  static CompassService get instance => _instance ??= CompassService._();

  CompassService._();

  StreamController<CompassEvent>? _compassController;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  double _lastHeading = 0.0;

  /// Stream للحصول على اتجاه البوصلة
  /// Stream to get compass heading
  Stream<CompassEvent>? get events {
    if (_compassController == null || _compassController!.isClosed) {
      _compassController = StreamController<CompassEvent>.broadcast(
        onListen: _startListening,
        onCancel: _stopListening,
      );
    }
    return _compassController?.stream;
  }

  void _startListening() {
    _magnetometerSubscription = magnetometerEvents.listen(
      (MagnetometerEvent event) {
        // حساب الاتجاه من قيم magnetometer
        // Calculate heading from magnetometer values
        double heading = _calculateHeading(event.x, event.y);

        // تطبيق تصفية بسيطة لتقليل التذبذب
        // Apply simple filtering to reduce jitter
        double smoothedHeading = _smoothHeading(heading);

        _lastHeading = smoothedHeading;

        if (!(_compassController?.isClosed ?? true)) {
          _compassController?.add(CompassEvent(
            heading: smoothedHeading,
            headingForCameraMode: smoothedHeading,
            accuracy: 0.0, // sensors_plus لا يوفر دقة
          ));
        }
      },
      onError: (error) {
        if (!(_compassController?.isClosed ?? true)) {
          _compassController?.addError(error);
        }
      },
    );
  }

  void _stopListening() {
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
  }

  /// حساب الاتجاه من قيم X و Y
  /// Calculate heading from X and Y values
  double _calculateHeading(double x, double y) {
    // حساب الزاوية بالراديان
    double heading = math.atan2(y, x);

    // تحويل إلى درجات
    heading = heading * (180.0 / math.pi);

    // تطبيع القيمة لتكون بين 0 و 360
    if (heading < 0) {
      heading += 360;
    }

    return heading;
  }

  /// تطبيق تصفية بسيطة للاتجاه
  /// Apply simple filtering to heading
  double _smoothHeading(double newHeading) {
    // معامل التنعيم (0.0 - 1.0)
    // كلما كان أقرب لـ 1، كلما كانت الاستجابة أسرع
    const double smoothingFactor = 0.3;

    // معالجة الانتقال من 359 إلى 0 والعكس
    double diff = newHeading - _lastHeading;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    double smoothed = _lastHeading + (diff * smoothingFactor);

    // تطبيع النتيجة
    if (smoothed < 0) {
      smoothed += 360;
    } else if (smoothed >= 360) {
      smoothed -= 360;
    }

    return smoothed;
  }

  /// التحقق من توفر البوصلة
  /// Check if compass is available
  Future<bool> isAvailable() async {
    try {
      final completer = Completer<bool>();
      final subscription = magnetometerEvents.listen(
        (event) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        cancelOnError: true,
      );

      // انتظر لمدة ثانيتين للتأكد
      Future.delayed(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      final result = await completer.future;
      await subscription.cancel();
      return result;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _stopListening();
    _compassController?.close();
    _compassController = null;
  }
}

/// حدث البوصلة - متوافق مع flutter_compass API
/// Compass event - compatible with flutter_compass API
class CompassEvent {
  final double? heading;
  final double? headingForCameraMode;
  final double? accuracy;

  CompassEvent({
    this.heading,
    this.headingForCameraMode,
    this.accuracy,
  });
}
