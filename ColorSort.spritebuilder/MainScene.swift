//
//  MainScene2.swift
//  ColorSort
//
//  Created by Ikey Benzaken on 10/2/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation
import GameKit

class MainScene: CCScene {
    weak var colorSorterLabel: CCLabelTTF!
    weak var playButton: CCButton!
    override func onEnter() {
        super.onEnter()
        iAdHandler.sharedInstance.loadAds(bannerPosition: .Bottom)
        setUpGameCenter()
        colorSorterLabel.string = NSLocalizedString("colorSorter", comment: "")
        playButton.title = NSLocalizedString("play", comment: "")
    }
    func play() {
        CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("Gameplay"))
    }
}

extension MainScene: GKGameCenterControllerDelegate {
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
