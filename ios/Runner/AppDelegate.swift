import Flutter
import UIKit
import google_mobile_ads
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
      // TODO: Register ListTileNativeAdFactory
        let listTileFactory = ListTileNativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "listTile", nativeAdFactory: listTileFactory)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
