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
    weak var soundEffectsLabel: CCLabelTTF!
    weak var backgroundMusicLabel: CCLabelTTF!
    weak var tutorialToggleButton: CCButton!
    
    override func onEnter() {
        super.onEnter()
        updateEffectsLabel()
        updateBgButtonLabel()
        if GameStateSingleton.sharedInstance.shouldPlayTutorial {
            tutorialToggleButton.title = "Tutorial: On"
        } else {
            tutorialToggleButton.title = "Tutorial: Off"
        }
    }
   
    func tutorialToggle() {
        if GameStateSingleton.sharedInstance.shouldPlayTutorial {
            GameStateSingleton.sharedInstance.shouldPlayTutorial = false
            tutorialToggleButton.title = "Tutorial: Off"
        } else {
            GameStateSingleton.sharedInstance.shouldPlayTutorial = true
            tutorialToggleButton.title = "Tutorial: On"
        }
    }
    func toggleEffectsEnabled() {
        if GameStateSingleton.sharedInstance.soundeffectsEnabled == true {
            GameStateSingleton.sharedInstance.soundeffectsEnabled = false
            updateEffectsLabel()
            
        } else if GameStateSingleton.sharedInstance.soundeffectsEnabled == false {
            GameStateSingleton.sharedInstance.soundeffectsEnabled = true
            updateEffectsLabel()
        }
    }
    func toggleBackgroundMusic() {
        if GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            GameStateSingleton.sharedInstance.backgroundMusicEnabled = false
        } else if !GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            GameStateSingleton.sharedInstance.backgroundMusicEnabled = true
        }
        updateBgButtonLabel()
    }
    
    func updateEffectsLabel () {
        if GameStateSingleton.sharedInstance.soundeffectsEnabled == true {
            soundEffectsLabel.string = "Sound Effects: On"
        } else if GameStateSingleton.sharedInstance.soundeffectsEnabled == false {
            soundEffectsLabel.string = "Sound Effects: Off"
        }
    }
    
    func updateBgButtonLabel() {
        if GameStateSingleton.sharedInstance.backgroundMusicEnabled == true {
            backgroundMusicLabel.string = "Music: On"
        } else if GameStateSingleton.sharedInstance.backgroundMusicEnabled == false {
            backgroundMusicLabel.string = "Music: Off"
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
