part of '../events.dart';

class CalendarBuild extends StatelessWidget {
  final int firstDayWeekday;
  final int daysInMonth;
  final HijriCalendar month;
  CalendarBuild(
      {super.key,
      required this.firstDayWeekday,
      required this.daysInMonth,
      required this.month});

  final eventCtrl = EventController.instance;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayOffset = index - firstDayWeekday + 1;
        if (dayOffset < 1 || dayOffset > daysInMonth) {
          return const SizedBox();
        }

        final isCurrentDay = eventCtrl.isCurrentDay(month, dayOffset).value;

        List<int> myMonths = [month.hMonth];
        return GestureDetector(
          onTap: eventCtrl.isEvent(myMonths, dayOffset).value
              ? () => eventCtrl.showEvent(dayOffset, month.hMonth)
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: eventCtrl.getDayColor(isCurrentDay, myMonths, dayOffset),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReactiveNumberText(
                    text: dayOffset.toString().convertNumbers(),
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 16,
                      height: 1.5,
                      color: isCurrentDay
                          ? context.theme.colorScheme.primaryContainer
                          : context.theme.textTheme.bodyLarge!.color,
                      fontWeight:
                          isCurrentDay ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  ReactiveNumberText(
                    text: eventCtrl.hijriNow
                        .hijriToGregorian(eventCtrl.calenderMonth.value.hYear,
                            eventCtrl.calenderMonth.value.hMonth, dayOffset)
                        .day
                        .toString()
                        .convertNumbers(),
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 10,
                      height: 1.3,
                      color: isCurrentDay
                          ? context.theme.colorScheme.primaryContainer
                          : context.theme.colorScheme.inversePrimary
                              .withValues(alpha: .5),
                      fontWeight:
                          isCurrentDay ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
