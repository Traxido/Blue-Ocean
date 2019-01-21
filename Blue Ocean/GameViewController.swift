//
//  GameViewController.swift
//  PrimalTest
//
//  Created by Andrew Sheron on 12/21/18.
//  Copyright © 2018 Andrew Sheron. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
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
            view.presentScene(scene)
            money = globalMoney
            moneyLabel.text = "$\(money)"
            self.updateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
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
