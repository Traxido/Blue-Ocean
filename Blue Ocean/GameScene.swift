//
//  GameScene.swift
//  Blue Ocean
//
//  Created by Andrew Sheron on 1/13/19.
//  Copyright © 2019 Andrew Sheron. All rights reserved.
//

import SpriteKit
import GameplayKit

var globalMoney = 0
var globalDistanceLeft = 0
var globalStars = 0

class GameScene: SKScene {
    
    //
    //
    //  VARIABLES
    //
    //
    
    //boat specifics
    var boatReach = CGFloat()
    var listOfBoatReachCoords : [CGFloat] = []
    var bubblesOffsetY = CGFloat()
    
    //sprite nodes
    var masterBoat = SKSpriteNode()
    var woodBoat = SKSpriteNode()
    var beach = SKSpriteNode()
    var beachWater = SKSpriteNode()
    
    //particles
    var boatBubbles = SKEmitterNode()
    var itemBubbles = SKEmitterNode()
    var splash = SKEmitterNode()
    
    //label nodes
    var moneyNode = SKLabelNode(fontNamed: "RifficFree-Bold")
    
    //user specific
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
    
    func removeNodeAnimation(node: SKSpriteNode) {
        
        node.removeAllActions()
        node.zPosition = 100
        
        let itemSpeed = frame.size.width / 1.0
        let moveDifference = CGPoint(x: masterBoat.position.x - node.position.x, y: masterBoat.position.y - node.position.y)
        let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
        let moveDuration = distanceToMove / itemSpeed
        
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 0),
            .repeatForever(.sequence([
                .move(to: masterBoat.position, duration: (TimeInterval(moveDuration))),
                .removeFromParent()
                ]))
            ]))
        
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 0),
            .repeatForever(.sequence([
                .scale(by: 1.5, duration: (TimeInterval(moveDuration/2))),
                .scale(by: 0.2, duration: (TimeInterval(moveDuration/2)))
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
        boatBubbles.position = CGPoint(x: 0, y: 0 - bubblesOffsetY)
        boatBubbles.particleScale = CGFloat(0.3)
        boatBubbles.zPosition = -1
        boatBubbles.particleScale = CGFloat(0.1)
        Node.addChild(boatBubbles)
    }
    
    func animateBeachWater() {
        beachWater.run(.sequence([
            .wait(forDuration: 10),
            .repeatForever(.sequence([
                .move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 105), duration: 1.2),
                .move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 140), duration: 0.8)
                ]))
            ]))
    }
    
    func animateBeach() {
        beach.run(.sequence([
            .wait(forDuration: 10),
            .repeatForever(.sequence([
                .move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 90), duration: 0.8),
                .move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 120), duration: 1.2)
                ]))
            ]))
    }
    
    func bringNodeIntoView(node: SKSpriteNode, position: CGPoint) {
        node.run(.sequence([
            .wait(forDuration: TimeInterval() * 2),
            .repeatForever(.sequence([
                .move(to: position, duration: 10)
                ]))
            ]))
    }
    
    func boatLands() {
        masterBoat.run(.sequence([
            .wait(forDuration: 10),
            .sequence([
                .move(to: CGPoint(x: self.frame.width / 2, y: (beach.position.y) - 850), duration: 1.5)
                ])
            ]))
    }
    
    func beachAppear() {
        
        addGarbageTimer?.invalidate()
        
        let origin = (self.frame.height)*2
        
        beach = SKSpriteNode.init(imageNamed: "beach")
        beach.position = CGPoint(x: self.frame.width / 2, y: origin - 100)
        beach.zPosition = 2
        beach.size = CGSize(width: 600, height: 300)
        self.addChild(beach)
        
        let dock = SKSpriteNode.init(imageNamed: "dock")
        dock.size = CGSize(width: 30, height: 550)
        dock.position = CGPoint(x: (self.frame.width / 2) - 5, y: origin)
        dock.zPosition = 3
        self.addChild(dock)
        
//        woodBoat = SKSpriteNode.init(imageNamed: "woodBoat")
//        woodBoat.size = CGSize(width: 100, height: 100)
//        woodBoat.position = CGPoint(x: (beach.frame.width / 8), y: (beach.position.y) + 30)
//        woodBoat.name = "woodBoat"
//        woodBoat.zPosition = 3
//        woodBoat.zRotation = (20 * .pi) / 180
//        self.addChild(woodBoat)
        
        beachWater = SKSpriteNode.init(imageNamed: "beachWater")
        beachWater.position = CGPoint(x: self.frame.width / 2, y: origin - 125)
        beachWater.zPosition = 1
        beachWater.size = CGSize(width: 600, height: 300)
        self.addChild(beachWater)
        
        bringNodeIntoView(node: beach, position: CGPoint(x: self.frame.width / 2, y: self.frame.height - 100))
        bringNodeIntoView(node: beachWater, position: CGPoint(x: self.frame.width / 2, y: self.frame.height - 125))
        bringNodeIntoView(node: dock, position: CGPoint(x: (self.frame.width / 3), y: self.frame.height))
        
        animateBeach()
        animateBeachWater()
        boatLands()
        
        boatBubbles.run(.sequence([.wait(forDuration: 7),.fadeOut(withDuration: 4)]))
    }
    
    func removeItem(node: SKSpriteNode) {
        
        globalMoney += 10
        moneyNode.text = "$\(globalMoney)"
        addedCash()
        
        let valueSprite = SKLabelNode(fontNamed: "RifficFree-Bold")
        valueSprite.color = UIColor.white
        valueSprite.text = "$10"
        valueSprite.position = CGPoint(x: node.position.x, y: node.position.y + 10)
        valueSprite.fontSize = 18
        valueSprite.zPosition = 10
        valueSprite.isUserInteractionEnabled = true
        self.addChild(valueSprite)
        
        removeNodeAnimation(node: node)
        animateValue(labelNode: valueSprite)
        
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
        
        bubblesOffsetY = 30
        boatReach = 50
        for i in Int((self.frame.width / 2) - boatReach )...Int((self.frame.width / 2) + boatReach ) {
            listOfBoatReachCoords.append(CGFloat(i))
        }
        
        masterBoat = SKSpriteNode.init(imageNamed: "bigBoat")
        masterBoat.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        masterBoat.size = CGSize(width: 250, height: 250)
        masterBoat.zPosition = 10
        self.addChild(masterBoat)
        animateNodes(node: masterBoat)
        addBoatBubbles(Node: masterBoat)
        
        moneyNode.text = "$\(globalMoney)"
        moneyNode.fontSize = 20
        moneyNode.position = CGPoint(x: self.frame.minX + 60, y: self.frame.height - 42)
        moneyNode.fontColor = UIColor(red:0.49, green:0.75, blue:0.29, alpha:1.0)
        moneyNode.zPosition = 5
        //self.addChild(moneyNode)
        
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
                    removeItem(node: targetNode as! SKSpriteNode)
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
        
        let boatMaxY = masterBoat.frame.maxY
        
        for i in 0...(listOfBoatReachCoords.count - 1) {
            
            let targetNode = atPoint(CGPoint(x: listOfBoatReachCoords[i], y: boatMaxY))
            
            if targetNode == self {
                
            } else if targetNode.name == "garbage" {
                
                targetNode.name = "removedGarbage"
                targetNode.isUserInteractionEnabled = true
                removeItem(node: targetNode as! SKSpriteNode)
                
            } else {
                
            }
        }
        
}
}

