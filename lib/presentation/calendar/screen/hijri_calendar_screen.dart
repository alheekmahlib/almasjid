// part of '../events.dart';

// class HijriDateScreen extends StatelessWidget {
//   HijriDateScreen({super.key});

//   final eventsCtrl = EventController.instance;

//   @override
//   Widget build(BuildContext context) {
//     eventsCtrl.resetDate();
//     return BackgroundAndTabbarWidget(
//       isHomeScreen: true,
//       isCenterChild: true,
//       isQuranSetting: false,
//       isNotification: false,
//       isCalendarSetting: true,
//       child: context.customOrientation(
//         Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Column(
//               children: [
//                 const Gap(16.0),
//                 Hero(
//                     tag: 'hijri_month',
//                     child: HijriDate(
//                       withIcon: false,
//                       padding:
//                           const EdgeInsetsDirectional.fromSTEB(22, 0, 0, 0),
//                     )),
//                 const Gap(16.0),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Transform.translate(
//                           offset: Offset(alignmentLayout(-10.0, 10.0), 0),
//                           child: BigCarveFlipXWidget(
//                             flipX: alignmentLayout(true, false),
//                             color: context.theme.colorScheme.secondaryContainer,
//                             child: const YearSelection(),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Transform.translate(
//                           offset: Offset(alignmentLayout(10.0, -10.0), 0),
//                           child: BigCarveFlipYWidget(
//                             flipY: alignmentLayout(false, true),
//                             color: context.theme.colorScheme.surface
//                                 .withValues(alpha: .5),
//                             child: const MonthSelection(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Gap(16),
//                 DaysName(),
//                 const Gap(8),
//                 const DaysBuildWidget(),
//               ],
//             ),
//             CustomSheetWidget(
//               minSheetOffset: .35,
//               child: GetBuilder<EventController>(
//                 builder: (eventCtrl) => AllCalculatingEventsWidget(),
//               ),
//             ),
//           ],
//         ),
//         Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                     flex: 4,
//                     child: Column(
//                       children: [
//                         const Gap(16),
//                         Hero(
//                             tag: 'hijri_month',
//                             child: HijriDate(
//                               withIcon: false,
//                               padding: const EdgeInsetsDirectional.fromSTEB(
//                                   22, 0, 0, 0),
//                             )),
//                         const Gap(16.0),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 child: Transform.translate(
//                                   offset:
//                                       Offset(alignmentLayout(-10.0, 10.0), 0),
//                                   child: BigCarveFlipXWidget(
//                                     flipX: alignmentLayout(true, false),
//                                     color: context
//                                         .theme.colorScheme.secondaryContainer,
//                                     child: const YearSelection(),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Transform.translate(
//                                   offset:
//                                       Offset(alignmentLayout(10.0, -10.0), 0),
//                                   child: BigCarveFlipYWidget(
//                                     flipY: alignmentLayout(false, true),
//                                     color: context.theme.colorScheme.surface
//                                         .withValues(alpha: .5),
//                                     child: const MonthSelection(),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     )),
//                 Expanded(
//                     flex: 4,
//                     child: Column(
//                       children: [
//                         const Gap(16),
//                         DaysName(),
//                         const Gap(8),
//                         const DaysBuildWidget(),
//                       ],
//                     )),
//               ],
//             ),
//             CustomSheetWidget(
//               minSheetOffset: .35,
//               child: GetBuilder<EventController>(
//                 builder: (eventCtrl) => AllCalculatingEventsWidget(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
