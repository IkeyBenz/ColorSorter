//
//  Store.swift
//  ColorSort
//
//  Created by Ikey Benzaken on 8/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class Store: CCScene, InAppPurchasesDelegate, sharingDelegate, ChartboostDelegate {
    
    weak var buySwipesButton: CCButton!
    weak var amountOfSwipesLabel: CCLabelTTF!
    weak var reviewButton: CCButton!
    weak var reviewExplaination: CCLabelTTF!
    weak var buttonsNode: CCNode!
    var wroteReview: Bool = false
    
    var didWriteReview = NSUserDefaults.standardUserDefaults().boolForKey("userWroteReview")
    
    override func onEnter() {
        let kChartboostAppID = "55e2b3170d60252dd5a3b10d";
        let kChartboostAppSignature = "f9fdd445ee21890d8d8871519ad32899a1f3d527";
        Chartboost.startWithAppId(kChartboostAppID, appSignature: kChartboostAppSignature, delegate: self);
        Chartboost.cacheRewardedVideo(CBLocationItemStore)
        
        updateLabel()
    }
    
    func didLoadFromCCB() {
        iAdHandler.sharedInstance.loadAds(bannerPosition: .Bottom)
        iAdHandler.sharedInstance.displayBannerAd()
        InAppPurchases.sharedInstance.IAPdelegate = self
        SharingHandler.sharedInstance.delegate = self
        if didWriteReview {
            reviewButton.visible = false
            reviewExplaination.visible = false
            buttonsNode.position.y = 0.87
            
        }
        print("Store Loaded")
    }
    
    func tryAgain() {
        CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("Gameplay"))
    }
    func writeAReview() {
        if !wroteReview {
            if let url = NSURL(string: "https://appsto.re/us/PVxC9.i") {
                UIApplication.sharedApplication().openURL(url)
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userWroteReview")
            wroteReview = true
            reviewExplaination.string = "Thanks for your support!"
            GameStateSingleton.sharedInstance.swipesLeft += 2
            updateLabel()
        } else {
            reviewButton.title = "Already wrote a review!"
        }
    }
    func watchAnAd() {
        if Chartboost.hasRewardedVideo(CBLocationItemStore) {
            Chartboost.showRewardedVideo(CBLocationItemStore)
            Chartboost.cacheRewardedVideo(CBLocationItemStore)
            GameStateSingleton.sharedInstance.swipesLeft += 1
            updateLabel()
        } else {
            let alert = UIAlertView()
            alert.title = "OH NO!!!"
            alert.message = "Looks like the ads could not load!"
            alert.addButtonWithTitle("That sucks")
            alert.show()
        }
    }
    func shareWithFriends() {
        SharingHandler.sharedInstance.postToTwitter(stringToPost: "Can't stop playing Color Sorter! #mustBeatMyHighScore", postWithScreenshot: true)
    }
    func purchaseSwipes() {
        InAppPurchases.sharedInstance.attemptPurchase("slowMotionSwipes")
    }
    
    
    func initializingIAP(IAPisInitializing: Bool) {
        if IAPisInitializing {
            buySwipesButton.title = "Initializing..."
        }
        
    }
    func IAPFinished(IAPFinishedInitializing: Bool, swipesWerePurchased: Bool) {
        if IAPFinishedInitializing {
            buySwipesButton.title = "Buy Swipes"
        }
        if swipesWerePurchased {
            animateLabel()
            updateLabel()
        }
    }
    func userPressedShareWithFriends(userDidShare: Bool) {
        if userDidShare {
            updateLabel()
        }
    }
    func updateLabel() {
        amountOfSwipesLabel.string = "Swipes Left: \(GameStateSingleton.sharedInstance.swipesLeft)"
    }
    func animateLabel() {
        let delay = CCActionDelay(duration: 1)
        let callblock = CCActionCallBlock(block: {self.animationManager.runAnimationsForSequenceNamed("Swipes Label")})
        runAction(CCActionSequence(array: [delay, callblock]))
    }
    
    
    
    
    
    
}