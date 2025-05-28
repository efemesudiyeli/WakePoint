//
//  BannerContentView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 23.05.2025.
//

import GoogleMobileAds
import SwiftUI

struct BannerViewContainer: UIViewRepresentable {
    let adSize: AdSize

    init(_ adSize: AdSize) {
        self.adSize = adSize
    }

    func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
    }

    func updateUIView(_: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }

    func makeCoordinator() -> BannerCoordinator {
        BannerCoordinator(self)
    }

    class BannerCoordinator: NSObject, BannerViewDelegate {
        let adUnitID = Bundle.main.infoDictionary?["BANNER_AD_UNIT_ID"] as? String ?? ""

        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView(adSize: parent.adSize)
            banner.adUnitID = adUnitID
            banner.load(Request())
            banner.delegate = self
            return banner
        }()

        let parent: BannerViewContainer

        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
            print("bannerViewDidReceiveAd")
        }

        func bannerView(_: BannerView, didFailToReceiveAdWithError error: Error) {
            print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_: BannerView) {
            print("bannerViewDidRecordImpression")
        }

        func bannerViewWillPresentScreen(_: BannerView) {
            print("bannerViewWillPresentScreen")
        }

        func bannerViewWillDismissScreen(_: BannerView) {
            print("bannerViewWillDIsmissScreen")
        }

        func bannerViewDidDismissScreen(_: BannerView) {
            print("bannerViewDidDismissScreen")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)

            VStack {
                BannerViewContainer(adSize)
                    .frame(height: adSize.size.height)
            }
        }
    }
}
