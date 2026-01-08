import 'dart:convert';

import 'package:arabic_justified_text/arabic_justified_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '/core/utils/constants/extensions/svg_extensions.dart';
import '/core/utils/constants/extensions/text_span_extension.dart';
import '/core/widgets/app_bar_widget.dart';
import '../../core/utils/constants/svg_constants.dart';
import '../calendar/events.dart';

part 'controller/teaching_prayer_controller.dart';
part 'data/model/sunnahs_and_heresies_model.dart';
part 'data/model/teaching_prayer_model.dart';
part 'screen/teaching_prayer_screen.dart';
part 'widgets/branch_tile.dart';
part 'widgets/custom_open_container.dart';
part 'widgets/section_card.dart';
part 'widgets/sunnahs_and_heresies.dart';
