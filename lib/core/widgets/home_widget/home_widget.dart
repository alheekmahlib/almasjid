import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:home_widget/home_widget.dart';

import '/core/services/macos_widget_service.dart';
import '/core/utils/constants/extensions/convert_number_extension.dart';
import '/core/utils/constants/string_constants.dart';
import '/core/utils/helpers/app_router.dart';
import '../../../presentation/calendar/events.dart';
import '../../../presentation/home/home.dart';
import '../../../presentation/prayers/prayers.dart';
import '../../utils/constants/lists.dart';
import '../../utils/helpers/date_formatter.dart';

part 'hijri_widget/hijri_widget_config.dart';
part 'prayers_widget/prayers_widget_config.dart';
