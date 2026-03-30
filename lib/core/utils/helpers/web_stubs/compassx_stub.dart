/// Web stub for compassx package
library;

class CompassXEvent {
  final double heading;
  final double accuracy;

  CompassXEvent({this.heading = 0.0, this.accuracy = 0.0});
}

class CompassX {
  static Stream<CompassXEvent> get events => const Stream.empty();
}
