/// Web stub for huawei_site
library;

class SearchService {
  static Future<SearchService> create({String? apiKey}) async =>
      SearchService();

  Future<TextSearchResponse> textSearch(TextSearchRequest request) async =>
      TextSearchResponse();
}

class TextSearchRequest {
  final String? query;
  final Coordinate? location;
  final int? radius;
  final HwLocationType? hwPoiType;
  final String? language;
  final int? pageSize;

  TextSearchRequest({
    this.query,
    this.location,
    this.radius,
    this.hwPoiType,
    this.language,
    this.pageSize,
  });
}

class TextSearchResponse {
  List<Site?>? sites;
}

class Coordinate {
  final double? lat;
  final double? lng;

  Coordinate({this.lat, this.lng});
}

// ignore: constant_identifier_names
enum HwLocationType { GEOCODE }

class Site {
  String? name;
  Coordinate? location;
  Address? address;
  String? formatAddress;
  Poi? poi;
}

class Poi {
  List<String>? poiTypes;
}

class Address {
  String? country;
  String? adminArea;
  String? locality;
}
