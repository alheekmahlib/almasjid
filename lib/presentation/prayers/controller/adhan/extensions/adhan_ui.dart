part of '../../../prayers.dart';

extension AdhanUi on AdhanController {
  /// -------- [OnTaps] ----------

  Future<void> hanafiOnTap(bool value) async {
    // تفعيل المذهب الحنفي وإلغاء تفعيل الشافعي - Activate Hanafi madhab and deactivate Shafi'i
    state.isHanafi = value;
    state.box.write(SHAFI, state.isHanafi);
    state.isLoadingPrayerData.value = true;
    await initializeStoredAdhan(forceUpdate: true);
  }

  Future<void> adjustPrayerTime(int index, {bool isAdding = true}) async {
    log("Before adjustment: ${prayerNameList[index]['adjustment']}");
    state.adjustments.addAdjustment(
      prayerNameList[index]['sharedAdjustment'],
      isAdding ? 1 : -1,
    );

    log("After adjustment: ${prayerNameList[index]['adjustment']}");
    state.box.remove(PRAYER_TIME_DATE);
    state.box.remove(PRAYER_TIME);
    state.isLoadingPrayerData.value = true;
    await initializeStoredAdhan(forceUpdate: true);
  }

  Future<void> switchAutoCalculation(bool value) async {
    state.autoCalculationMethod.value = value;
    // sl<NotificationController>().initializeNotification();
    state.box.write(AUTO_CALCULATION, value);
    state.isLoadingPrayerData.value = true;
    initializeStoredAdhan(forceUpdate: true);
  }

  Future<void> notificationOptionsOnTap(int i, int prayerIndex) async {
    await PrayersNotificationsCtrl.instance.scheduleDailyNotificationsForPrayer(
      prayerIndex,
      prayerNameList[prayerIndex]['title'],
      notificationOptions[i]['title'],
    );
    update(['change_notification']);
  }
}
