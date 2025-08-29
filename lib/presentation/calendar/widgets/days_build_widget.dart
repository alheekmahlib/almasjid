part of '../events.dart';

class DaysBuildWidget extends StatelessWidget {
  const DaysBuildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventController>(
        builder: (eventCtrl) => Flexible(
              // height: 240,
              child: PageView.builder(
                controller: eventCtrl.pageController,
                onPageChanged: eventCtrl.onMonthChanged,
                physics: const ClampingScrollPhysics(),
                itemCount: 12,
                itemBuilder: (context, monthIndex) {
                  eventCtrl.calenderMonth.value = eventCtrl.months[monthIndex];
                  final daysInMonth = eventCtrl.getDaysInMonth(
                      eventCtrl.calenderMonth.value,
                      eventCtrl.calenderMonth.value.hYear,
                      eventCtrl.calenderMonth.value.hMonth);
                  final firstDayWeekday = eventCtrl.calculateFirstDayOfMonth(
                      eventCtrl.calenderMonth.value.hMonth,
                      eventCtrl.calenderMonth.value.hYear);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: CalendarBuild(
                      daysInMonth: daysInMonth,
                      firstDayWeekday: firstDayWeekday,
                      month: eventCtrl.calenderMonth.value,
                    ),
                  );
                },
              ),
            ));
  }
}
