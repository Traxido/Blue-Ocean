//
//  GameScene.swift
//  Blue Ocean
//
//  Created by Andrew Sheron on 1/13/19.
//  Copyright © 2019 Andrew Sheron. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //
    //
    //  VARIABLES
    //
    //
    
    //sprite nodes
    var masterBoat = SKSpriteNode()
    var boatBubbles = SKEmitterNode()
    var splash = SKEmitterNode()
    
    //label nodes
    var moneyNode = SKLabelNode(fontNamed: "acme")
    
    //user specific
    var money : UInt = 0
    
    var levelMultipler = 1
    var level = 1
    
    //timers
    var removeTimer: Timer? = nil
    var addGarbageTimer: Timer? = nil
    
    //collections
    var potentialGarbage : [String] = ["baggie","book","book2","book3","book6","bottle","bottle1","bottle2","brush","cd","paper","paper1","paper2","paper3","paper4","plasticBag","tool","wheel"]
    var speedBoatImageNames = ["speedBoat1","speedBoat2","speedBoat3"]
    
    //
    //
    //  CUSTOM FUNCTIONS
    //
    //
    
    //animation functions
    func animateNodes(node: SKSpriteNode) {
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 0.2),
            .repeatForever(.sequence([
                .scale(to: 1.1, duration: 0.8),
                .scale(to: 1, duration: 0.8),
                .wait(forDuration: 0)
                ]))
            ]))
    }
    func addedCash() {
        moneyNode.run(.sequence([.scale(to: 1.2, duration: 0.1),
                                 .scale(to: 1, duration: 0.05)]))
    }
    
    func touchedNode(node: SKSpriteNode) {
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 0),
            .repeatForever(.sequence([
                .fadeOut(withDuration: 0.3)
                ]))
            ]))
        
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 0.2),
            .repeatForever(.sequence([
                .scale(to: 1.5, duration: 0.4),
                .removeFromParent()
                ]))
            ]))
    }
    
    func animateValue(labelNode: SKLabelNode) {
        labelNode.run(.sequence([
            .wait(forDuration: TimeInterval() * 2),
            .repeatForever(.sequence([
                .move(to: CGPoint(x: labelNode.position.x, y: labelNode.position.y + 10), duration: 0.3),
                .fadeOut(withDuration: 0.3),
                .removeFromParent()
                ]))
            ]))
    }
    
    func addBoatBubbles(Node: SKSpriteNode) {
        let desiredPath = Bundle.main.path(forResource: "Bubbles", ofType: "sks")
        boatBubbles = NSKeyedUnarchiver.unarchiveObject(withFile: desiredPath!) as! SKEmitterNode
        boatBubbles.position = CGPoint(x: 0, y: 0)
        boatBubbles.particleScale = CGFloat(0.3)
        boatBubbles.zPosition = -1
        boatBubbles.particleScale = CGFloat(0.1)
        boatBubbles.isUserInteractionEnabled = true
        Node.addChild(boatBubbles)
    }
    
    //timer functions
    @objc func addGarbage() {
        let rand = Int(arc4random_uniform(UInt32(potentialGarbage.count)))
        let garbageSpriteToAdd = SKSpriteNode(imageNamed: potentialGarbage[rand])
        
        let randX = Int(arc4random_uniform(UInt32(self.frame.width)))
        
        garbageSpriteToAdd.position.x = CGFloat(randX)
        garbageSpriteToAdd.position.y = CGFloat(self.frame.height + 50)
        garbageSpriteToAdd.size = CGSize(width: 32, height: 32)
        
        garbageSpriteToAdd.name = "garbage"
        animateNodes(node: garbageSpriteToAdd)
        self.addChild(garbageSpriteToAdd)
        
        var newLocation = CGPoint()
        newLocation = CGPoint(x: randX, y: -50)
        
        garbageSpriteToAdd.run(.sequence([.move(to: newLocation, duration: 10),.removeFromParent()]))
        
    }
    
    //random actions
    func boatDriveBy() {
        let randomSpeedBoat = Int(arc4random_uniform(UInt32(speedBoatImageNames.count)))
        let speedBoat = SKSpriteNode.init(imageNamed: speedBoatImageNames[randomSpeedBoat])
        print(speedBoatImageNames[randomSpeedBoat])
        speedBoat.size = CGSize(width: 100, height: 100)
        speedBoat.zPosition = 10
        speedBoat.position = CGPoint(x: (self.frame.width / 4)*3, y: -200)
        self.addChild(speedBoat)
        addBoatBubbles(Node: speedBoat)
        animateNodes(node: speedBoat)
        speedBoat.run(.sequence([
            .wait(forDuration: TimeInterval() * 0),
            .repeatForever(.sequence([
                .wait(forDuration: 5),
                .move(to: CGPoint(x: (self.frame.width / 8)*7, y: self.frame.height + 200), duration: 5),
                .removeFromParent()
                ]))
            ]))
    }
    
    //
    //
    //  OVERRIDE FUNCTIONS
    //
    //
    
    override func sceneDidLoad() {
        
        boatDriveBy()
        masterBoat = SKSpriteNode.init(imageNamed: "boaty")
        masterBoat.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        masterBoat.size = CGSize(width: 100, height: 100)
        masterBoat.zPosition = 1
        self.addChild(masterBoat)
        animateNodes(node: masterBoat)
        addBoatBubbles(Node: masterBoat)
        
        moneyNode.text = "$\(money)"
        moneyNode.fontSize = 24
        moneyNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 30)
        moneyNode.zPosition = 5
        self.addChild(moneyNode)
        
        self.addGarbageTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(addGarbage), userInfo: nil, repeats: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in (touches) {
                
                let location = touch.location(in: self)
                let targetNode = atPoint(location)
                
                if targetNode == self {
                    
                } else if targetNode == masterBoat {
                    
                } else if targetNode.name == "garbage" {
                
                targetNode.isUserInteractionEnabled = true
                
                money += 10
                moneyNode.text = "$\(money)"
                addedCash()
                    
                let valueSprite = SKLabelNode(fontNamed: "acme")
                valueSprite.color = UIColor.white
                valueSprite.text = "$10"
                valueSprite.position = CGPoint(x: targetNode.position.x, y: targetNode.position.y + 10)
                valueSprite.fontSize = 18
                valueSprite.zPosition = 10
                valueSprite.isUserInteractionEnabled = true
                self.addChild(valueSprite)
                
                touchedNode(node: targetNode as! SKSpriteNode)
                animateValue(labelNode: valueSprite)
                    
                }
                let desiredPath = Bundle.main.path(forResource: "waterSplash", ofType: "sks")
                splash = NSKeyedUnarchiver.unarchiveObject(withFile: desiredPath!) as! SKEmitterNode
                splash.position = location
                splash.particleScale = CGFloat(0.3)
                splash.zPosition = -1
                splash.particleScale = CGFloat(0.1)
                splash.isUserInteractionEnabled = true
                self.addChild(splash)
                
                splash.run(.sequence([
                    .wait(forDuration: TimeInterval() * 0),
                    .repeatForever(.sequence([
                        .wait(forDuration: 1),
                        .removeFromParent()
                        ]))
                    ]))
        }
        
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(red:0.00, green:0.84, blue:0.84, alpha:1.0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    

    

}

