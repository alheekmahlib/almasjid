// part of '../events.dart';

// class MonthSelection extends StatelessWidget {
//   const MonthSelection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<EventController>(
//       builder: (eventCtrl) => Padding(
//         padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 0, 0),
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
//                 onPressed: () {
//                   if (eventCtrl.pageController.page! > 0) {
//                     eventCtrl.pageController.previousPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//               ),
//             ),
//             Expanded(
//               flex: 6,
//               child: Center(
//                 child: CustomDropdown<HijriDateConfig>(
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
//                   hintBuilder: (context, _, select) => FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       eventCtrl.calenderMonth.value.getLongMonthName().tr,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.inversePrimary,
//                         fontSize: 16,
//                         fontFamily: 'cairo',
//                       ),
//                     ),
//                   ),
//                   maxlines: 1,
//                   items: List.generate(12, (index) {
//                     var hijri = HijriDateConfig();
//                     hijri.hYear = eventCtrl.selectedDate.hYear;
//                     hijri.hMonth = index + 1;
//                     hijri.hDay = 1;
//                     return hijri;
//                   }),
//                   listItemBuilder: (context, months, select, _) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 4.0, vertical: 4.0),
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(8)),
//                       color: months.getLongMonthName().tr ==
//                               eventCtrl.hijriNow.getLongMonthName().tr
//                           ? Theme.of(context)
//                               .colorScheme
//                               .surface
//                               .withValues(alpha: .2)
//                           : eventCtrl.selectedDate.getLongMonthName().tr ==
//                                   months.getLongMonthName().tr
//                               ? Theme.of(context)
//                                   .colorScheme
//                                   .primary
//                                   .withValues(alpha: .2)
//                               : Colors.transparent,
//                     ),
//                     child: SizedBox(
//                       width: 80,
//                       child: Text(
//                         months.getLongMonthName().tr,
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.inversePrimary,
//                           fontSize: 16,
//                           fontFamily: 'naskh',
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   headerBuilder: (context, calendar, _) => FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       eventCtrl.calenderMonth.value.getLongMonthName().tr,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.inversePrimary,
//                         fontSize: 16,
//                         fontFamily: 'cairo',
//                       ),
//                     ),
//                   ),
//                   initialItem: null,
//                   onChanged: (value) {
//                     log('changing value to: $value');
//                     eventCtrl.pageController.animateToPage(
//                       value!.hMonth - 1,
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                     eventCtrl.calenderMonth.value = value;
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
//                 onPressed: () {
//                   if (eventCtrl.pageController.page! < 11) {
//                     eventCtrl.pageController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
