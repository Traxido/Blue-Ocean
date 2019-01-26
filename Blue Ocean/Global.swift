//
//  Constants.swift
//  Blue Ocean
//
//  Created by Andrew Sheron on 1/23/19.
//  Copyright © 2019 Andrew Sheron. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let adMobMyDeviceUUID = "0a2573dacdf8286e0212cf7ee6f6a00af19b7b36"
let adMobApplicationId = "ca-app-pub-7949947864760784~2701429580"
let adMobBannerAdUnitId = "ca-app-pub-7949947864760784/6316530527"
let adMobInterstitialAdUnitId = "ca-app-pub-7949947864760784/7410120345"
let adMobRewardBasedVideoAdUnitId = "ca-app-pub-7949947864760784/8148486944"

var soundOn = false
var trackTrash = true

var levels : [Int] = [100]

class boat {
    var name = String()
    var imageName = String()
    var tierLevel = Int()
    var bubblesOffset = CGFloat()
    var adsNeeded = Int()
    var cost = Int()
    var owned = false
    var multiplier = 1
}

var globalMoney = 0
var globalStars = 0
var globalXp = 100
var globalLvl = 0
var globalTrashPickedUp = 0
var globalWorth = 1
var globalMultiplier = 1

var globalChangedBoat = false

var globalBoats : [boat] = []

