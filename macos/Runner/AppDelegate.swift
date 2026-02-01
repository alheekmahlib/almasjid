import Cocoa
import FlutterMacOS
import WidgetKit

@main
class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.alheekmah.aqimApp.prayer-widget"
  private let appGroupId = "group.alheekmah.aqimApp.prayerWidget"

  private let sharedPayloadFileName = "widget_payload.json"

  private func appGroupContainerURL() -> URL? {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
  }

  private func readSharedPayloadFile() -> [String: Any] {
    guard let container = appGroupContainerURL() else {
      return [:]
    }

    let fileURL = container.appendingPathComponent(sharedPayloadFileName)
    do {
      let data = try Data(contentsOf: fileURL)
      if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
        return obj
      }
      return [:]
    } catch {
      return [:]
    }
  }

  private func writeSharedPayloadFile(_ payload: [String: Any]) {
    guard let container = appGroupContainerURL() else {
      NSLog("[MacOSWidget] containerURL(forSecurityApplicationGroupIdentifier:) returned nil for %@", appGroupId)
      return
    }

    let fileURL = container.appendingPathComponent(sharedPayloadFileName)
    do {
      var enriched = payload
      enriched["__writer_bundle_id"] = Bundle.main.bundleIdentifier ?? ""
      enriched["__writer_pid"] = ProcessInfo.processInfo.processIdentifier
      enriched["__writer_app_version"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
      enriched["__writer_build"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

      let data = try JSONSerialization.data(withJSONObject: enriched, options: [])
      try data.write(to: fileURL, options: [.atomic])
      NSLog("[MacOSWidget] Wrote shared payload file: %@", fileURL.path)
    } catch {
      NSLog("[MacOSWidget] Failed writing shared payload file: %@", String(describing: error))
    }
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.engine.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(FlutterError(code: "unavailable", message: "AppDelegate deallocated", details: nil))
          return
        }

        switch call.method {
        case "initialize":
          if let ud = UserDefaults(suiteName: self.appGroupId) {
            ud.set(Date().description, forKey: "__macos_widget_initialized")
            ud.synchronize()
          }

          // File-based marker (more reliable than CFPreferences on some macOS setups)
          // IMPORTANT: merge markers into existing payload to avoid wiping prayer data
          // between app launches.
          var payload = self.readSharedPayloadFile()
          payload["__macos_widget_initialized"] = Date().description
          payload["lastUpdated"] = Date().description
          self.writeSharedPayloadFile(payload)
          result(nil)

        case "updatePrayerData":
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "bad_args", message: "Expected map arguments", details: nil))
            return
          }

          self.storePrayerData(args)
          WidgetCenter.shared.reloadAllTimelines()
          result(nil)

        case "reloadAllTimelines":
          WidgetCenter.shared.reloadAllTimelines()
          result(nil)

        case "reloadTimeline":
          guard let args = call.arguments as? [String: Any],
                let kind = args["widgetKind"] as? String else {
            result(FlutterError(code: "bad_args", message: "Expected widgetKind", details: nil))
            return
          }
          WidgetCenter.shared.reloadTimelines(ofKind: kind)
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  private func storePrayerData(_ args: [String: Any]) {
    guard let ud = UserDefaults(suiteName: appGroupId) else {
      NSLog("[MacOSWidget] Failed to open UserDefaults suite: %@", appGroupId)
      return
    }

    func normalizeDateString(_ s: String) -> String {
      // Supports either "yyyy-MM-dd HH:mm:ss.SSS" (Dart toString)
      // or ISO-8601 strings (Dart toIso8601String). We normalize to
      // "yyyy-MM-dd HH:mm:ss.SSS" in local time.
      let iso = ISO8601DateFormatter()
      iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      let altIso = ISO8601DateFormatter()
      altIso.formatOptions = [.withInternetDateTime]

      let df = DateFormatter()
      df.calendar = Calendar(identifier: .gregorian)
      df.locale = Locale(identifier: "en_US_POSIX")
      df.timeZone = TimeZone.current
      df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

      if let d = iso.date(from: s) ?? altIso.date(from: s) {
        return df.string(from: d)
      }
      return s
    }

    // نخزن فقط القيم النصية المتوقعة (نفس مفاتيح iOS قدر الإمكان)
    let expectedKeys: [String] = [
      "fajrTime", "sunriseTime", "dhuhrTime", "asrTime", "maghribTime", "ishaTime",
      "middleOfTheNightTime", "lastThirdOfTheNightTime",
      "fajrName", "sunriseName", "dhuhrName", "asrName", "maghribName", "ishaName",
      "middleOfTheNightName", "lastThirdOfTheNightName",
      "hijriDay", "hijriDayName", "hijriMonth", "hijriYear",
      "currentPrayerName", "nextPrayerName", "currentPrayerTime", "nextPrayerTime",
      "appLanguage",
      // الشهرية
      "monthly_prayer_data",
      // تشخيص
      "lastUpdated"
    ]

    var payload: [String: Any] = [:]

    for key in expectedKeys {
      if let value = args[key] as? String {
        if key.hasSuffix("Time") {
          let normalized = normalizeDateString(value)
          ud.set(normalized, forKey: key)
          payload[key] = normalized
        } else {
          ud.set(value, forKey: key)
          payload[key] = value
        }
        continue
      }

      // monthly_prayer_data قد يصل كـ Map/Array حسب المصدر؛ نحوله إلى JSON String.
      if key == "monthly_prayer_data", let anyValue = args[key] {
        if JSONSerialization.isValidJSONObject(anyValue),
           let data = try? JSONSerialization.data(withJSONObject: anyValue, options: []),
           let json = String(data: data, encoding: .utf8) {
          ud.set(json, forKey: key)
          payload[key] = json
        } else if let json = anyValue as? String {
          ud.set(json, forKey: key)
          payload[key] = json
        }
      }
    }

    // Diagnostic marker
    ud.set(Date().description, forKey: "__macos_widget_last_write")
    payload["__macos_widget_last_write"] = Date().description

    // Also persist a JSON payload file in the App Group container.
    // This avoids CFPreferences/cfprefsd issues where suite reads return nil.
    self.writeSharedPayloadFile(payload)

    ud.synchronize()
  }
}
