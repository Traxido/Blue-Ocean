//
//  GameViewController.swift
//  PrimalTest
//
//  Created by Andrew Sheron on 12/21/18.
//  Copyright © 2018 Andrew Sheron. All rights reserved.
//

import UIKit
import SpriteKit

var tier = 9

class GameViewController: UIViewController {
    
    var boats : [boat] = []
    
    var selectetBoat = boat()
    
    var updateTimer: Timer? = nil
    var money = Int()
    var stars = Int()
    
    override func viewDidLoad() {
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
            money = globalMoney
            moneyLabel.text = "$\(money)"
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
    
    @objc func update() {
        money = globalMoney
        moneyLabel.text = "$\(money)"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
