// part of '../events.dart';

// class YearSelection extends StatelessWidget {
//   const YearSelection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<EventController>(
//       builder: (eventCtrl) => Padding(
//         padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 14, 0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   padding: const EdgeInsets.all(0),
//                   shadowColor: Colors.transparent,
//                 ),
//                 child: Icon(
//                   Icons.arrow_left,
//                   size: 30,
//                   color: context.theme.hintColor,
//                 ),
//                 onPressed: () =>
//                     eventCtrl.onYearChanged(eventCtrl.selectedDate.hYear - 1),
//               ),
//             ),
//             Expanded(
//               flex: 6,
//               child: Center(
//                 child: CustomDropdown<int>(
//                   excludeSelected: false,
//                   decoration: CustomDropdownDecoration(
//                     closedFillColor: context.theme.colorScheme.primaryContainer,
//                     expandedFillColor:
//                         context.theme.colorScheme.primaryContainer,
//                     closedBorderRadius:
//                         const BorderRadius.all(Radius.circular(8)),
//                   ),
//                   closedHeaderPadding: const EdgeInsets.symmetric(
//                       vertical: 4.0, horizontal: 8.0),
//                   itemsListPadding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   listItemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   // hintText: 'المدة',
//                   hintBuilder: (context, _, select) => FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: ReactiveNumberText(
//                       text: '${eventCtrl.selectedDate.hYear}'.convertNumbers(),
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.inversePrimary,
//                         fontSize: 16,
//                         fontFamily: 'cairo',
//                       ),
//                     ),
//                   ),

//                   items: List.generate(
//                     eventCtrl.endYear! - eventCtrl.startYear! + 1,
//                     (index) => eventCtrl.startYear! + index,
//                   ),
//                   listItemBuilder: (context, index, select, _) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 4.0, vertical: 4.0),
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(8)),
//                       color: eventCtrl.hijriNow.hYear == index
//                           ? Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withValues(alpha: .2)
//                           : select
//                               ? Theme.of(context)
//                                   .colorScheme
//                                   .surface
//                                   .withValues(alpha: .2)
//                               : Colors.transparent,
//                     ),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: ReactiveNumberText(
//                         text: '$index ${'AH'.tr}'.convertNumbers(),
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.inversePrimary,
//                           fontSize: 18,
//                           fontFamily: 'naskh',
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   initialItem: null,
//                   onChanged: (value) {
//                     log('changing value to: $value');
//                     eventCtrl.onYearChanged(value!);
//                     // khatmahCtrl.daysController.text =
//                     //     (value! + 1).toString();
//                   },
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   padding: const EdgeInsets.all(0),
//                   shadowColor: Colors.transparent,
//                 ),
//                 child: Icon(
//                   Icons.arrow_right,
//                   size: 30,
//                   color: context.theme.hintColor,
//                 ),
//                 onPressed: () =>
//                     eventCtrl.onYearChanged(eventCtrl.selectedDate.hYear + 1),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
