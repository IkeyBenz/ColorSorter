//
//  PausedScreen.swift
//  ColorSort
//
//  Created by Ikey Benzaken on 8/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import GameKit

class PausedScreen: CCNode {
    weak var tutorialToggleButton: CCButton!
    weak var musicButton: CCButton!
    weak var soundFXButton: CCButton!
    weak var highscoreButton: CCButton!
    weak var pausedLabel: CCLabelTTF!
    
    func didLoadFromCCB() {
        highscoreButton.title = NSLocalizedString("highscores", comment: "")
        pausedLabel.string = NSLocalizedString("paused", comment: "")
        if GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            musicButton.title = NSLocalizedString("musicOn", comment: "")
        } else {
            musicButton.title = NSLocalizedString("musicOff", comment: "")
        }
        
        if GameStateSingleton.sharedInstance.soundeffectsEnabled {
            soundFXButton.title = NSLocalizedString("soundFXon", comment: "")
        } else {
            soundFXButton.title = NSLocalizedString("soundFXoff", comment: "")
        }
        
        if GameStateSingleton.sharedInstance.shouldPlayTutorial {
            tutorialToggleButton.title = NSLocalizedString("tutorialOn", comment: "")
        } else {
            tutorialToggleButton.title = NSLocalizedString("tutorialOff", comment: "")
        }
    }
    
    func toggleBackgroundMusic() {
        if GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            GameStateSingleton.sharedInstance.backgroundMusicEnabled = false
            musicButton.title = NSLocalizedString("musicOff", comment: "")
        } else if !GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            GameStateSingleton.sharedInstance.backgroundMusicEnabled = true
            musicButton.title = NSLocalizedString("musicOn", comment: "")
        }
    }
    
    func toggleEffectsEnabled() {
        if GameStateSingleton.sharedInstance.soundeffectsEnabled == true {
            GameStateSingleton.sharedInstance.soundeffectsEnabled = false
            soundFXButton.title = NSLocalizedString("soundFXoff", comment: "")
            
        } else if GameStateSingleton.sharedInstance.soundeffectsEnabled == false {
            GameStateSingleton.sharedInstance.soundeffectsEnabled = true
            soundFXButton.title = NSLocalizedString("soundFXon", comment: "")
        }
    }
   
    func tutorialToggle() {
        if GameStateSingleton.sharedInstance.shouldPlayTutorial {
            GameStateSingleton.sharedInstance.shouldPlayTutorial = false
            tutorialToggleButton.title = NSLocalizedString("tutorialOff", comment: "")
        } else {
            GameStateSingleton.sharedInstance.shouldPlayTutorial = true
            tutorialToggleButton.title = NSLocalizedString("tutorialOn", comment: "")
        }
    }
    
    
    
}

extension PausedScreen: GKGameCenterControllerDelegate {
    func showLeaderboard() {
        let viewController = CCDirector.sharedDirector().parentViewController!
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
}
