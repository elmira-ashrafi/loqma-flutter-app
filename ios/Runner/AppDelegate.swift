import Flutter
import GoogleMaps
import UIKit
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty,
       !key.hasPrefix("REPLACE_") {
      GMSServices.provideAPIKey(key)
    }

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "delivery.loqma/cdn_cookies",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getCookies":
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
          result(FlutterError(code: "invalid", message: "url required", details: nil))
          return
        }
        let targetHost = url.host?.lowercased() ?? ""
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
          let filtered = cookies.filter { cookie in
            let domain = cookie.domain.lowercased()
            return domain == targetHost || domain.hasPrefix(".") && targetHost.hasSuffix(domain)
          }
          let header = filtered.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
          result(header)
        }

      case "setCookies":
        // Currently unused by the Dart bridge; keep as a no-op for forward compatibility.
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
