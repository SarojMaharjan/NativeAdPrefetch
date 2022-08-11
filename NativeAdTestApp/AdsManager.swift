//
//  AdsManager.swift
//  NativeAdTestApp
//
//  Created by Saroj Maharjan on 10/08/2022.
//

import Foundation
import GoogleMobileAds

class AdsManager: NSObject {
    
    static var shared: AdsManager = {
        let instance = AdsManager()
        return instance
    }()
    private var cachedAds = AdsCache<AdUnit, GADNativeAd>()
    private var adLoaders: [AdUnit: GADAdLoader] = [:]
    private var adLoaderErrors: [AdUnit: Error] = [:]
    private var adFetchListeners: [AdUnit: (GADNativeAd?, Error?) -> Void] = [:]
    
    override init() {
        super.init()
//        fetchAds(for: AdUnit.allCases)
    }
    
    func initialize() {
        fetchAds(for: AdUnit.allCases)
    }
    
    private func fetchAds(for adUnits: [AdUnit]) {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = adUnits.count
        for unit in adUnits {
            let adLoader = GADAdLoader(adUnitID: unit.rawValue, rootViewController: nil, adTypes: [.native], options: [multipleAdsOptions])
            adLoader.delegate = self
            adLoaders[unit] = adLoader
            adLoader.load(GADRequest())
        }
    }
    
    private func standingAdCount() -> Int {
        return AdUnit.allCases.count
    }
    
    func getAd(for unit: AdUnit, onAdFetched: @escaping((GADNativeAd?, Error?) -> Void)) {
        if let currentAd = cachedAds.value(forKey: unit) {
            onAdFetched(currentAd, nil)
        } else if let loader = adLoaders[unit] {
            if loader.isLoading {
                adFetchListeners[unit] = onAdFetched
            }
        } else if let error = adLoaderErrors[unit] {
            onAdFetched(nil, error)
            adLoaderErrors.removeValue(forKey: unit)
        } else {
            fetchNewAd(forUnit: unit)
        }
    }
    
    private func fetchNewAd(forUnit unit: AdUnit) {
        let adLoader = GADAdLoader(adUnitID: unit.rawValue, rootViewController: nil, adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoaders[unit] = adLoader
        adLoader.load(GADRequest())
    }
    
    func renewAd(forUnit unit: AdUnit) {
        fetchNewAd(forUnit: unit)
    }
    
    func clearListeners(for unit: AdUnit) {
        adLoaders.removeValue(forKey: unit)
    }
    
    func clearAllListeners() {
        adLoaders.removeAll()
    }
}
extension AdsManager: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        if let adUnit = AdUnit(rawValue: adLoader.adUnitID) {
//            nativeAd.delegate = self
            cachedAds.insert(nativeAd, forKey: adUnit)
            adLoaders.removeValue(forKey: adUnit)
            if let listener = adFetchListeners[adUnit] {
                listener(nativeAd, nil)
//                adFetchListeners.removeValue(forKey: adUnit)
            }
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        if let adUnit = AdUnit(rawValue: adLoader.adUnitID) {
            adLoaderErrors[adUnit] = error
            adLoaders.removeValue(forKey: adUnit)
            if let listener = adFetchListeners[adUnit] {
                listener(nil, error)
//                adFetchListeners.removeValue(forKey: adUnit)
            }
        }
    }
    
}
//extension AdsManager: GADNativeAdDelegate {
//    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
//        print("The add was clicked")
//        renewAd(forUnit: .home)
//    }
//
//    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
//        print("The add recorded impression")
//    }
//
//}
