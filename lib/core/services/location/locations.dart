import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

import '/core/utils/helpers/web_stubs/google_huawei_availability_stub.dart'
    if (dart.library.io) 'package:google_huawei_availability/google_huawei_availability.dart';
import '/core/utils/helpers/web_stubs/huawei_location_stub.dart'
    if (dart.library.io) 'package:huawei_location/huawei_location.dart'
    as hms_location;
import '/core/utils/helpers/web_stubs/huawei_site_stub.dart'
    if (dart.library.io) 'package:huawei_site/huawei_site.dart' as hms_site;
import '/core/utils/helpers/web_stubs/io_stub.dart'
    if (dart.library.io) 'dart:io';
import '../../../presentation/controllers/general/general_controller.dart';
import '../../utils/constants/shared_preferences_constants.dart';

part 'huawei_location_helper.dart';
part 'location.dart';
part 'location_exception.dart';
part 'location_helper.dart';
part 'nominatim_reverse_geocoding_service.dart';
