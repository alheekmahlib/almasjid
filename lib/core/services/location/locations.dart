import 'dart:developer';
import 'dart:io';

// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

import '../../../presentation/controllers/general/general_controller.dart';
import '../../utils/constants/shared_preferences_constants.dart';

part 'location.dart';
part 'location_exception.dart';
part 'location_helper.dart';
