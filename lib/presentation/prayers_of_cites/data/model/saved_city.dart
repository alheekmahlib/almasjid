part of '../../cites.dart';

class SavedCity {
  final String id;
  final String name;
  final String countryDisplay;
  final String countryRaw;
  final double latitude;
  final double longitude;
  final int sortOrder;
  final String? fullAddress;

  const SavedCity({
    required this.id,
    required this.name,
    required this.countryDisplay,
    required this.countryRaw,
    required this.latitude,
    required this.longitude,
    required this.sortOrder,
    this.fullAddress,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  static String buildId(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)},${longitude.toStringAsFixed(5)}';
  }

  SavedCity copyWith({
    String? id,
    String? name,
    String? countryDisplay,
    String? countryRaw,
    double? latitude,
    double? longitude,
    int? sortOrder,
    String? fullAddress,
  }) {
    return SavedCity(
      id: id ?? this.id,
      name: name ?? this.name,
      countryDisplay: countryDisplay ?? this.countryDisplay,
      countryRaw: countryRaw ?? this.countryRaw,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortOrder: sortOrder ?? this.sortOrder,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryDisplay': countryDisplay,
      'countryRaw': countryRaw,
      'latitude': latitude,
      'longitude': longitude,
      'sortOrder': sortOrder,
      'fullAddress': fullAddress,
    };
  }

  factory SavedCity.fromJson(Map<String, dynamic> json) {
    return SavedCity(
      id: (json['id'] as String?) ??
          SavedCity.buildId(
            (json['latitude'] as num?)?.toDouble() ?? 0.0,
            (json['longitude'] as num?)?.toDouble() ?? 0.0,
          ),
      name: (json['name'] as String?) ?? '',
      countryDisplay: (json['countryDisplay'] as String?) ?? '',
      countryRaw: (json['countryRaw'] as String?) ??
          (json['countryDisplay'] as String?) ??
          '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      fullAddress: json['fullAddress'] as String?,
    );
  }
}
