//
//  UnifiedAdView.swift
//  NativeAdTestApp
//
//  Created by Saroj Maharjan on 03/08/2022.
//

import UIKit
import GoogleMobileAds

class UnifiedAdView: UIView {
    var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    //
    private func commonInit() {
        let bundle = Bundle(for: UnifiedAdView.self)
        containerView = UINib(nibName: "UnifiedAdView", bundle: bundle).instantiate(withOwner: self).first as? UIView
        containerView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView!.frame = bounds
        addSubview(containerView!)
    }
    
    func setUpAd(_ ad: GADNativeAd) {
        guard let nativeAdView = containerView as? GADNativeAdView else {
            return
        }
        if let headerText = nativeAdView.headlineView as? UILabel, let header = ad.headline {
            headerText.text = header
        }
        if let iconView = nativeAdView.iconView as? UIImageView, let icon = ad.icon?.image {
            iconView.image = icon
        }
        if let callToActionView = nativeAdView.callToActionView as? UIButton {
            callToActionView.setTitle(ad.callToAction, for: .normal)
            callToActionView.isHidden = ad.callToAction == nil
//            nativeAd?.register(self, clickableAssetViews: [GADNativeAssetIdentifier.callToActionAsset : callToActionView], nonclickableAssetViews: [:])
//            callToActionView.addTarget(self, action: #selector(clickyclicky), for: .touchUpInside)
        }
        
//         In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = ad
        
        
    }
    
}
