import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ضروري لوضع Implicit Engine: لا يضبط FlutterAppDelegate نفسه كمفوض
    // لمركز الإشعارات تلقائياً، وبغير هذا السطر لا تصل نقرات الإشعارات
    // إلى flutter_local_notifications إطلاقاً (FlutterAppDelegate يمرر
    // الأحداث للإضافات المسجلة عبر addApplicationDelegate).
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
