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

class GameViewController: UIViewController {
    
    var boats : [boat] = []
    
    var selectetBoat = boat()
    
    var updateTimer: Timer? = nil
    var money = Int()
    var stars = Int()
    var distance = Int()
    
    override func viewDidLoad() {
        
        presentAdMobBanner()
        createAndLoadPopUp()
        createAndLoadRewardBasedVideo()
        
        settingsView.isHidden = true
        logView.isHidden = true
        moneyView.isHidden = true
        inventoryView.isHidden = true
        dockedView.isHidden = true
        
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
            
            globalDistanceLeft = 1
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
    @IBOutlet weak var distanceLeft: UILabel!
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var inventoryView: UIView!
    @IBOutlet weak var dockedView: UIView!
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    fileprivate var popUpAd: GADInterstitial!
    fileprivate var rewardBasedVide: GADRewardBasedVideoAd!
    
    fileprivate var rewardBasedVideoAsRequestInProgress = false
    
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
        
    }
    
    @IBAction func changeBoat(_ sender: Any) {
        if popUpAd.isReady {
            popUpAd.present(fromRootViewController: self)
        } else {
            print("Interstitial ad wasn't ready")
        }
        createAndLoadPopUp()
    }
    
    @IBAction func keepGoing(_ sender: Any) {
        if let view = view as? SKView {
            // Create the scene programmatically
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.presentScene(scene)
            settingsView.isHidden = true
            logView.isHidden = true
            moneyView.isHidden = true
            inventoryView.isHidden = true
            dockedView.isHidden = true
            globalDocked = false
            globalDistanceLeft = 15
    }
    }
    
    @objc func update() {
        money = globalMoney
        moneyLabel.text = "$\(money)"
        
        distance = globalDistanceLeft
        distanceLeft.text = "\(distance)km"
        
        if globalDocked == true {
            distanceLeft.text = "Docked"
            dockView()
        }
        
    }
    
    func dockView() {
        settingsView.isHidden = false
        logView.isHidden = false
        moneyView.isHidden = false
        inventoryView.isHidden = false
        dockedView.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
