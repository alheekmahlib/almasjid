import 'dart:convert';

import 'package:almasjid/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hijri_calendar/hijri_calendar.dart';

import '../../../core/widgets/reactive_number_text.dart';

part 'controller/event_controller.dart';
part 'data/model/event_model.dart';
part 'widgets/calculating_date_events_widget.dart';
part 'widgets/calendar_build.dart';
part 'widgets/days_build_widget.dart';
part 'widgets/days_name.dart';
