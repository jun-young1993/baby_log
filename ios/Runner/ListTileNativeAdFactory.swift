// TODO: Import google_mobile_ads
import google_mobile_ads
import UIKit

// TODO: Implement ListTileNativeAdFactory
class ListTileNativeAdFactory : FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: NativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        
        // Create NativeAdView programmatically instead of using XIB
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
        containerView.addSubview(bodyView)
        containerView.addSubview(callToActionView)
        nativeAdView.addSubview(containerView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -8),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            headlineView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            headlineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            bodyView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            bodyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            bodyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            callToActionView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            callToActionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            callToActionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            callToActionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            callToActionView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Assign views
        nativeAdView.headlineView = headlineView
        nativeAdView.bodyView = bodyView
        nativeAdView.callToActionView = callToActionView
        nativeAdView.iconView = iconView
        
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
        
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}
