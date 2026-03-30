/// Web stub for huawei_location
class FusedLocationProviderClient {
  Future<Location> getLastLocation() async => Location();
}

class Location {
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  double? horizontalAccuracyMeters;
}
