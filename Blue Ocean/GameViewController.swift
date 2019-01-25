//
//  GameViewController.swift
//  PrimalTest
//
//  Created by Andrew Sheron on 12/21/18.
//  Copyright © 2018 Andrew Sheron. All rights reserved.
//

import GoogleMobileAds
import UIKit
import SpriteKit

var tier = 9

class GameViewController: UIViewController, GADRewardBasedVideoAdDelegate {
    
    var boats : [boat] = []
    
    var selectetBoat = boat()
    
    var updateTimer: Timer? = nil
    var money = Int()
    var stars = Int()
    
    override func viewDidLoad() {
        
        presentAdMobBanner()
        createAndLoadPopUp()
        createAndLoadRewardBasedVideo()
        
        super.viewDidLoad()
        if let view = view as? SKView {
            // Create the scene programmatically
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            scene.passedMasterBoat.tierLevel = 4
            view.presentScene(scene)
            self.updateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
            initBoat(imgName: "woodBoat", tier: 1)
            initBoat(imgName: "patrolBoat", tier: 2)
            initBoat(imgName: "freighter", tier: 3)
            initBoat(imgName: "aircraftCarrier", tier: 4)
            
            passMasterBoat = boats[2]
        }
    }
    
    func initBoat(imgName: String, tier: Int) {
        let newBoat = boat()
        newBoat.name = imgName
        newBoat.imageName = imgName
        newBoat.tierLevel = tier
        
        boats.append(newBoat)
    }
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var inventoryView: UIView!
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    fileprivate var popUpAd: GADInterstitial!
    fileprivate var rewardBasedVideo: GADRewardBasedVideoAd!
    
    fileprivate var rewardBasedVideoAdRequestInProgress = false
    
    // MARK: GADRewardBasedVideoAdDelegate implementation
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        rewardBasedVideoAdRequestInProgress = false
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        rewardBasedVideoAdRequestInProgress = false
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
    }
    
    fileprivate func presentAdMobBanner() {
        bannerView.adUnitID = "ca-app-pub-7949947864760784/6316530527"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID,"dc1f504ed2168b38feed13bfd04b7271"]
        bannerView.load(request)
    }
    
    fileprivate func createAndLoadPopUp() {
        popUpAd = GADInterstitial(adUnitID: adMobInterstitialAdUnitId)
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID, adMobMyDeviceUUID ]
        popUpAd.load(request)
    }
    
    fileprivate func createAndLoadRewardBasedVideo() {
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        if !rewardBasedVideoAdRequestInProgress && rewardBasedVideo?.isReady == false {
            rewardBasedVideo?.load(GADRequest(),
                                   withAdUnitID: adMobRewardBasedVideoAdUnitId)
            rewardBasedVideoAdRequestInProgress = true
        }
    }
    
    @IBAction func changeBoat(_ sender: Any) {
    }
    
    fileprivate func presentRewardBasedVideoAd() {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        } else {
            print("Reward Based Video Ad wasn't ready")
        }
        createAndLoadRewardBasedVideo()
    }
    
    func presentPopUpAd() {
        if popUpAd.isReady {
            popUpAd.present(fromRootViewController: self)
        } else {
            print("Interstitial ad wasn't ready")
        }
        createAndLoadPopUp()
    }
    
    @objc func update() {
        money = globalMoney
        moneyLabel.text = "$\(money)"
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
