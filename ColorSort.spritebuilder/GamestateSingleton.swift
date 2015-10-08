//
//  Singleton.swift
//  Seige
//
//  Created by Luke Solomon on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameStateSingleton: NSObject {
    
    var alreadyLoaded: Bool = NSUserDefaults.standardUserDefaults().boolForKey("AlreadyLoaded1.4.1") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(alreadyLoaded, forKey: "AlreadyLoaded1.4.1")
        }
    }
    
    var highscore: Int = NSUserDefaults.standardUserDefaults().integerForKey("Highscore") {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highscore, forKey: "Highscore")
        }
    }
    
    var soundeffectsEnabled: Bool = NSUserDefaults.standardUserDefaults().boolForKey("EffectsEnabled") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(soundeffectsEnabled, forKey: "EffectsEnabled")
        }
    }
    
    var backgroundMusicEnabled: Bool = NSUserDefaults.standardUserDefaults().boolForKey("BackgroundMusicEnabled") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(backgroundMusicEnabled, forKey: "BackgroundMusicEnabled")
        }
    }
    
    var swipesLeft: Int = NSUserDefaults.standardUserDefaults().integerForKey("SwipesLeft") {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(swipesLeft, forKey: "SwipesLeft")
        }
    }
    
    var swipeUpLabelWasShown: Bool = NSUserDefaults.standardUserDefaults().boolForKey("SwipeUpLabelWasShown") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(swipeUpLabelWasShown, forKey: "SwipeUpLabelWasShown")
        }
    }
    
    var shouldPlayTutorial: Bool = NSUserDefaults.standardUserDefaults().boolForKey("shouldPlayTutorial") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(shouldPlayTutorial, forKey: "shouldPlayTutorial")
        }
    }
    
    var screenShot: UIImage!
    
    
    class var sharedInstance : GameStateSingleton {
        struct Static {
            static let instance : GameStateSingleton = GameStateSingleton()
        }
        return Static.instance
    }
    
}