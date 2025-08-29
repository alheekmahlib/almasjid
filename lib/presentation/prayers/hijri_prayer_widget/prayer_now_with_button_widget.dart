// part of '../prayers.dart';

// class PrayerNowWithButtonWidget extends StatelessWidget {
//   final bool isWithButton;
//   PrayerNowWithButtonWidget({super.key, required this.isWithButton});

//   final prayerPBCtrl = PrayerProgressController.instance;
//   final adhanCtrl = AdhanController.instance;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AdhanController>(
//       id: 'update_progress',
//       builder: (adhanCtrl) {
//         if (!adhanCtrl.state.isPrayerTimesInitialized.value ||
//             adhanCtrl.state.prayerTimes == null ||
//             adhanCtrl.state.sunnahTimes == null) {
//           return const SizedBox.shrink();
//         }
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.secondaryContainer,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Gap(8),
//               Hero(
//                 tag: 'prayer_now',
//                 child: PrayerNowWidget(
//                   adhanCtrl: adhanCtrl,
//                 ),
//               ),
//               isWithButton
//                   ? context.hDivider(width: Get.width * .5)
//                   : const SizedBox.shrink(),
//               isWithButton
//                   ? Container(
//                       // width: Get.width,
//                       padding: const EdgeInsetsDirectional.fromSTEB(
//                           6.0, 8.0, 10.0, 8.0),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primary,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Expanded(
//                             flex: 9,
//                             child: SizedBox(
//                               height: 47,
//                               child: BigButtonWidget(
//                                 svgPath: SvgPath.svgPrayerLogo,
//                                 title: 'prayer',
//                                 screenRoute: AppRouter.prayerScreen,
//                               ),
//                             ),
//                           ),
//                           (Platform.isMacOS ||
//                                   Platform.isLinux ||
//                                   Platform.isWindows)
//                               ? const SizedBox.shrink()
//                               : const Expanded(
//                                   flex: 2,
//                                   child: Hero(
//                                     tag: 'qibla_tag',
//                                     child: SmallButtonWidget(
//                                       svgPath: SvgPath.svgQeblaLogo,
//                                       screenRoute: AppRouter.qiblaScreen,
//                                     ),
//                                   ),
//                                 ),
//                         ],
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
