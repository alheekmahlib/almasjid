import 'dart:developer' show log;
import 'dart:ui' as ui;

import 'package:adhan/adhan.dart';
import 'package:almasjid/core/utils/constants/lottie.dart';
import 'package:almasjid/core/utils/constants/lottie_constants.dart';
import 'package:almasjid/core/widgets/custom_button.dart';
import 'package:almasjid/presentation/controllers/theme_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
// import 'package:geodesy/geodesy.dart' as geodesy;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:turf/turf.dart' as turf;

import '/core/utils/constants/extensions/svg_extensions.dart';
import '/core/utils/constants/svg_constants.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/constants/lists.dart';
import '../../../core/utils/constants/shared_preferences_constants.dart';
import '../../core/widgets/app_bar_widget.dart';
import '../controllers/general/general_controller.dart';

part '../qibla/controller/qibla_controller.dart';
part '../qibla/screen/qibla_screen.dart';
part '../qibla/widgets/custom_painter.dart';
part '../qibla/widgets/qibla_compass_widget.dart';
part '../qibla/widgets/qibla_map_widget.dart';
part 'widgets/header_card_widget.dart';
