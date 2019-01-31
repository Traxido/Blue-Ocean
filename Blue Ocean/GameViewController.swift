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

class GameViewController: UIViewController, GADRewardBasedVideoAdDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return globalBoats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BuyBoatCollectionViewCell
        
        cell.boatImg.image = UIImage.init(named: globalBoats[indexPath.row].imageName)
        if globalBoats[indexPath.row].owned == true {
            cell.lockedImage.isHidden = true
        } else {
            cell.lockedImage.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        let boat = globalBoats[indexPath.row]
        watchAdsButton.isHidden = false
        
        boatPreviewImage.image = UIImage.init(named: boat.imageName)
        boatPreviewName.text = boat.name
        boatPreviewTier.text = "Tier \(boat.tierLevel) | \(boat.multiplier)x Multiplier"
        buyButton.setTitle("$\(boat.cost)", for: .normal)
        
        checkForNumberOfAds(index: currentIndex)
        
        if boat.owned == true {
            watchAdsButton.isHidden = true
            buyButton.setTitle("Choose", for: .normal)
        }
        
        if boat.adsNeeded > 0 {
            buyButton.isHidden = true
        } else {
            buyButton.isHidden = false
        }
    }
    
    @IBOutlet weak var boatPreviewImage: UIImageView!
    @IBOutlet weak var boatPreviewName: UILabel!
    @IBOutlet weak var boatPreviewTier: UILabel!
    
    
    @IBOutlet weak var buyBoatsCollectionView: UICollectionView!
    var boatsOwned : [Bool] = []
    
    var selectetBoat = boat()
    var currentIndex = 0
    
    var updateTimer: Timer? = nil
    var money = Int()
    var stars = Int()
    
    var adTimer: Timer? = nil
    
    override func viewDidLoad() {
        presentAdMobBanner()
        createAndLoadPopUp()
        createAndLoadRewardBasedVideo()
        
        self.adTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(presentPopUpAd), userInfo: nil, repeats: true)
        
        for i in 1...40 {
            let startXp = levels[levels.count-1]
            let newXp = Double(startXp) * 1.8
            levels.append(Int(newXp))
            print("Level \(i+1) = \(newXp)")
            if globalXp >= Int(newXp) {
                globalLvl = i
                levelLabel.text = "Lvl \(globalLvl)"
            } else {
                
            }
        }
        print(levels)
        
        super.viewDidLoad()
        if let view = view as? SKView {
            // Create the scene programmatically
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            //view.showsNodeCount = true
            scene.passedMasterBoat.tierLevel = 4
            view.presentScene(scene)
            self.updateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
            initBoat(name: "Wood Boat", imgName: "woodBoat", tier: 1, cost: 0, adsNeeded: 0, multiplier: 1)
            initBoat(name: "Sail Boat", imgName: "sailBoat", tier: 1, cost: 750, adsNeeded: 1, multiplier: 1)
            initBoat(name: "Patrol Boat", imgName: "patrolBoat", tier: 2, cost: 10000, adsNeeded: 2, multiplier: 2)
            initBoat(name: "Freighter", imgName: "freighter", tier: 3, cost: 200000, adsNeeded: 3, multiplier: 3)
            initBoat(name: "Freighter 2", imgName: "freighter2", tier: 3, cost: 210000, adsNeeded: 3, multiplier: 3)
            initBoat(name: "Tug Boat", imgName: "tugBoat", tier: 3, cost: 250000, adsNeeded: 3, multiplier: 3)
            initBoat(name: "Medium Yacht", imgName: "yacht_1", tier: 3, cost: 300000, adsNeeded: 3, multiplier: 4)
            initBoat(name: "Aircraft Carrier", imgName: "aircraftCarrier", tier: 4, cost: 5000000, adsNeeded: 5, multiplier: 4)
            globalBoats[0].owned = true
            passMasterBoat = globalBoats[0]
        }
    }
    
    func initBoat(name: String, imgName: String, tier: Int, cost: Int, adsNeeded: Int, multiplier: Int) {
        let newBoat = boat()
        newBoat.name = name
        newBoat.imageName = imgName
        newBoat.tierLevel = tier
        newBoat.cost = cost
        newBoat.adsNeeded = adsNeeded
        newBoat.multiplier = multiplier
        
        globalBoats.append(newBoat)
    }
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var settings: UIView!
    @IBAction func soundSwitch(_ sender: Any) {
        if soundOn == true {
            soundOn = false
        } else {
            soundOn = true
        }
    }
    
    @IBOutlet weak var buyBoats: UIView!
    @IBOutlet weak var watchAdsButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    
    @IBAction func buyBoat(_ sender: Any) {
        
        if globalBoats[currentIndex].owned == true {
            //play
            closeMenusProg()
            globalChangedBoat = true
            passMasterBoat = globalBoats[currentIndex]
            globalMultiplier = globalBoats[currentIndex].multiplier
            print(globalBoats[currentIndex].multiplier)
        } else {
            //Buy
            checkFunds(cost: globalBoats[currentIndex].cost)
        }
    }
    @IBAction func watchAds(_ sender: Any) {
        createAndLoadRewardBasedVideo()
        presentRewardBasedVideoAd()
    }
    
    
    
    
    
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
        createAndLoadRewardBasedVideo()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func checkForNumberOfAds(index: Int) {
        let adsNeeded = globalBoats[index].adsNeeded
        if adsNeeded == 0 {
            watchAdsButton.isHidden = true
            buyButton.isEnabled = true
            buyButton.isHidden = false
        } else {
            buyButton.isEnabled = false
            watchAdsButton.setTitle("Watch \(globalBoats[index].adsNeeded) Ads To Unlock", for: .normal)
        }
        buyBoatsCollectionView.reloadData()
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        globalBoats[currentIndex].adsNeeded -= 1
        checkForNumberOfAds(index: currentIndex)
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
    
    var anyMenuOpen = false
    
    @IBOutlet weak var menuUnderlay: UIButton!
    @IBAction func closeMenus(_ sender: Any) {
        closeMenusProg()
    }
    
    func closeMenusProg() {
        if anyMenuOpen == true {
            settings.isHidden = true
            buyBoats.isHidden = true
            menuUnderlay.isHidden = true
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
        anyMenuOpen = true
        settings.isHidden = false
        menuUnderlay.isHidden = false
    }
    
    @IBAction func openBoats(_ sender: Any) {
        anyMenuOpen = true
        buyBoats.isHidden = false
        menuUnderlay.isHidden = false
    }
    
    fileprivate func presentRewardBasedVideoAd() {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        } else {
            print("Reward Based Video Ad wasn't ready")
        }
        createAndLoadRewardBasedVideo()
    }
    
    @objc func presentPopUpAd() {
        if popUpAd.isReady {
            popUpAd.present(fromRootViewController: self)
            adTimer?.invalidate()
        } else {
            print("Interstitial ad wasn't ready")
        }
        createAndLoadPopUp()
    }
    
    func checkFunds(cost: Int) {
        if globalMoney >= cost {
            globalMoney -= cost
            watchAdsButton.isHidden = true
            globalBoats[currentIndex].owned = true
            buyButton.setTitle("Choose", for: .normal)
            buyBoatsCollectionView.reloadData()
            
            
            passMasterBoat = globalBoats[currentIndex]
        } else {
            print("Not Enough Funds")
        }
    }
    
    
    @objc func update() {
        money = globalMoney
        moneyLabel.text = "$\(money)"
        levelLabel.text = "Lvl \(globalLvl)"
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
