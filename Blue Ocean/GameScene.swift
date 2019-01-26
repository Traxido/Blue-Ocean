//
//  GameScene.swift
//  Blue Ocean
//
//  Created by Andrew Sheron on 1/13/19.
//  Copyright © 2019 Andrew Sheron. All rights reserved.
//

import SpriteKit
import GameplayKit

var passMasterBoat = boat()

class GameScene: SKScene {
    
    //
    //
    //  VARIABLES
    //
    //
    
    //Sound
    var splashSound = SKAction.playSoundFileNamed("splashSound.wav", waitForCompletion: false)
    
    //conversioons
    var passedMasterBoat = boat()
    
    let tier1Width : CGFloat = 30
    let tier2Width : CGFloat = 52
    let tier3Width : CGFloat = 100
    let tier4Width : CGFloat = 158
    
    let tier1Height : CGFloat = 54
    let tier2Height : CGFloat = 100
    let tier3Height : CGFloat = 240
    let tier4Height : CGFloat = 374
    
    let tier1BubbleOffset : CGFloat = 0
    let tier2BubbleOffset : CGFloat = 0
    let tier3BubbleOffset : CGFloat = 30
    let tier4BubbleOffset : CGFloat = 70
    
    var localTier = Int()
    
    //boat specifics
    var boatReach = CGFloat()
    var listOfBoatReachCoords : [CGFloat] = [-100]
    var bubblesOffsetY = CGFloat()
    var masterBoatWidth = CGFloat()
    var masterBoatHeight = CGFloat()
    
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
    var docking = false
    
    //timers
    var addGarbageTimer: Timer? = nil
    var loadBoat : Timer? = nil
    var playOceanSound : Timer? = nil
    
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
    
    func removeItem(node: SKSpriteNode) {
        
        globalMoney += globalWorth*level*globalMultiplier
        globalXp += 1
        moneyNode.text = "$\(globalMoney)"
        addedCash()
        
        let valueSprite = SKLabelNode(fontNamed: "RifficFree-Bold")
        valueSprite.color = UIColor.white
        valueSprite.text = "$\(globalWorth*level)"
        valueSprite.position = CGPoint(x: node.position.x, y: node.position.y + 10)
        valueSprite.fontSize = 18
        valueSprite.zPosition = 10
        valueSprite.isUserInteractionEnabled = true
        self.addChild(valueSprite)
        
        removeNodeAnimation(node: node)
        animateValue(labelNode: valueSprite)
        if soundOn == true {
            run(splashSound)
        }
        
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
    var waves = SKAction.playSoundFileNamed("waves.wav", waitForCompletion: false)
    
    @objc func playWaves() {
        if soundOn == true {
            run(waves)
        }
    }
    
    @objc func buildBoat() {
        
        masterBoat.removeFromParent()
        passedMasterBoat = passMasterBoat
        
        if passedMasterBoat.tierLevel == 1 {
            boatReach = tier1Width/2
            masterBoatWidth = tier1Width
            masterBoatHeight = tier1Height
            bubblesOffsetY = tier1BubbleOffset
        } else if passedMasterBoat.tierLevel == 2 {
            boatReach = tier2Width/2
            masterBoatWidth = tier2Width
            masterBoatHeight = tier2Height
            bubblesOffsetY = tier2BubbleOffset
        } else if passedMasterBoat.tierLevel == 3 {
            boatReach = tier3Width/2
            masterBoatWidth = tier3Width
            masterBoatHeight = tier3Height
            bubblesOffsetY = tier3BubbleOffset
        } else if passedMasterBoat.tierLevel == 4 {
            boatReach = tier4Width/2
            masterBoatWidth = tier4Width
            masterBoatHeight = tier4Height
            bubblesOffsetY = tier4BubbleOffset
        }
        
        listOfBoatReachCoords.removeAll()
        
        print(passedMasterBoat.imageName)
        for i in Int((self.frame.width / 2) - boatReach )...Int((self.frame.width / 2) + boatReach ) {
            listOfBoatReachCoords.append(CGFloat(i))
        }
        
        masterBoat = SKSpriteNode.init(imageNamed: passedMasterBoat.imageName)
        masterBoat.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        masterBoat.size = CGSize(width: masterBoatWidth, height: masterBoatHeight)
        masterBoat.zPosition = 10
        masterBoat.name = passedMasterBoat.imageName
        self.addChild(masterBoat)
        
        animateNodes(node: masterBoat)
        addBoatBubbles(Node: masterBoat)
        
        loadBoat?.invalidate()
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
        self.addGarbageTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(addGarbage), userInfo: nil, repeats: true)
        self.loadBoat = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(buildBoat), userInfo: nil, repeats: true)
        let waves = SKAction.playSoundFileNamed("waves.wav", waitForCompletion: false)
        
        if soundOn == true {
            run(waves)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in (touches) {
                
                let location = touch.location(in: self)
                let targetNode = atPoint(location)
                
                if targetNode == self {
                    
                    if soundOn == true {
                        run(splashSound)
                    }
                    
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
    
    var isSoundPlaying = true
    
    override func update(_ currentTime: TimeInterval) {
        
        if globalChangedBoat == true {
            buildBoat()
            globalChangedBoat = false
        }
        
        let boatMaxY = masterBoat.frame.maxY
        
        if soundOn == false {
            splashSound = SKAction()
            waves = SKAction()
            playOceanSound?.invalidate()
            isSoundPlaying = true
        } else {
            if isSoundPlaying == true {
                isSoundPlaying = false
                waves = SKAction.playSoundFileNamed("waves.wav", waitForCompletion: false)
                splashSound = SKAction.playSoundFileNamed("splashSound.wav", waitForCompletion: false)
                self.playOceanSound = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(playWaves), userInfo: nil, repeats: true)
                playWaves()
            } else {
                
            }
        }
        
        for i in 0...(listOfBoatReachCoords.count - 1) {
            
            let targetNode = atPoint(CGPoint(x: listOfBoatReachCoords[i], y: boatMaxY))
            
            if targetNode == self {
                
            } else if targetNode.name == "garbage" {
                
                targetNode.name = "removedGarbage"
                targetNode.isUserInteractionEnabled = true
                removeItem(node: targetNode as! SKSpriteNode)
                
                let desiredPath = Bundle.main.path(forResource: "waterSplash", ofType: "sks")
                splash = NSKeyedUnarchiver.unarchiveObject(withFile: desiredPath!) as! SKEmitterNode
                splash.position = (CGPoint(x: listOfBoatReachCoords[i], y: boatMaxY))
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
                
            } else {
                
            }
        }
        
}
}
