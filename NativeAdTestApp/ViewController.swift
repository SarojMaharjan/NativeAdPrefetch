//
//  ViewController.swift
//  NativeAdTestApp
//
//  Created by Saroj Maharjan on 03/08/2022.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {
    let AD_UNIT_ID = "ca-app-pub-3959126762877687/6032930774"
    
    private lazy var unifiedAdView: UnifiedAdView = {
        let view = UnifiedAdView()
        view.frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.width, height: 250)
        return view
    }()
    
    private var adLoader: GADAdLoader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(unifiedAdView)
        AdsManager.shared.getAd(for: .home) { nativeAd, error in
            guard error == nil else {
                print("Encountered error when fetching error")
                return
            }
            if let ad = nativeAd {
                ad.delegate = self
                self.unifiedAdView.setUpAd(ad)
            }
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        AdsManager.shared.clearListeners(for: .home)
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        AdsManager.shared.clearListeners(for: .home)
//    }
}
extension ViewController: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("The add was clicked")
        AdsManager.shared.renewAd(forUnit: .home)
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("The add recorded impression")
    }

}
