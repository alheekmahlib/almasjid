import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_huawei_availability/google_huawei_availability.dart';
import 'package:huawei_location/huawei_location.dart' as hms_location;
import 'package:huawei_site/huawei_site.dart' as hms_site;
import 'package:latlong2/latlong.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

import '../../../presentation/controllers/general/general_controller.dart';
import '../../utils/constants/shared_preferences_constants.dart';

part 'huawei_location_helper.dart';
part 'location.dart';
part 'location_exception.dart';
part 'location_helper.dart';
