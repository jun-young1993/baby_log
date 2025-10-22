import Flutter
import UIKit
import google_mobile_ads

class NativeAdFactoryExample : FLTNativeAdFactory {
    
    func createNativeAd(_ nativeAd: NativeAd,
                       customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        
        // Create NativeAdView programmatically
        let nativeAdView = NativeAdView()
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Container view
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        
        // Headline
        let headlineView = UILabel()
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 2
        
        // Body
        let bodyView = UILabel()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.font = UIFont.systemFont(ofSize: 14)
        bodyView.textColor = .darkGray
        bodyView.numberOfLines = 3
        
        // Star rating
        let starRatingView = UILabel()
        starRatingView.translatesAutoresizingMaskIntoConstraints = false
        starRatingView.font = UIFont.systemFont(ofSize: 12)
        starRatingView.textColor = .gray
        
        // Call to action
        let callToActionView = UIButton(type: .system)
        callToActionView.translatesAutoresizingMaskIntoConstraints = false
        callToActionView.backgroundColor = UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1.0)
        callToActionView.setTitleColor(.white, for: .normal)
        callToActionView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        callToActionView.layer.cornerRadius = 8
        
        // Add subviews
        containerView.addSubview(iconView)
        containerView.addSubview(headlineView)
        containerView.addSubview(starRatingView)
        containerView.addSubview(bodyView)
        containerView.addSubview(callToActionView)
        nativeAdView.addSubview(containerView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -16),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            headlineView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            starRatingView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
            starRatingView.leadingAnchor.constraint(equalTo: headlineView.leadingAnchor),
            
            bodyView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            bodyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            bodyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            callToActionView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 12),
            callToActionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            callToActionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            callToActionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            callToActionView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Assign views
        nativeAdView.headlineView = headlineView
        nativeAdView.bodyView = bodyView
        nativeAdView.callToActionView = callToActionView
        nativeAdView.iconView = iconView
        nativeAdView.starRatingView = starRatingView
        
        // Set data
        headlineView.text = nativeAd.headline
        bodyView.text = nativeAd.body
        bodyView.isHidden = nativeAd.body == nil
        
        callToActionView.setTitle(nativeAd.callToAction, for: .normal)
        callToActionView.isHidden = nativeAd.callToAction == nil
        
        if let icon = nativeAd.icon {
            iconView.image = icon.image
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        
        if let starRating = nativeAd.starRating {
            starRatingView.text = String(format: "%.1f ⭐", starRating.doubleValue)
            starRatingView.isHidden = false
        } else {
            starRatingView.isHidden = true
        }
        
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Native Ad Factory 등록
    let nativeAdFactory = NativeAdFactoryExample()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "listTile",
      nativeAdFactory: nativeAdFactory
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
