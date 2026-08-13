import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // google_maps_flutter needs the SDK provisioned with the API key here —
    // the GMSApiKey entry in Info.plist alone does nothing on iOS, unlike
    // Android's manifest meta-data equivalent. Read from Info.plist so the
    // key still has a single source of truth.
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
