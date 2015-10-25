//
//  Gameplay1.swift
//  ColorSorter
//
//  Created by Ikey Benzaken on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import GameKit
import AudioToolbox


class Gameplay: CCScene, ChartboostDelegate {
    
    // COLOR COLUMNS
    weak var yellowColumn: CCNodeColor!
    weak var greenColumn: CCNodeColor!
    weak var purpleColumn: CCNodeColor!
    weak var blueColumn: CCNodeColor!
    weak var pinkColumn: CCNodeColor!
    
    
    // GAMEPLAY PROPERTIES
    var colorSpeed: CCTime = 4
    var screenWidthPercent = CCDirector.sharedDirector().viewSize().width / 100
    var audio = OALSimpleAudio.sharedInstance()
    var currentTouchLocation: CGPoint!
    var colorNode: CCNodeColor!
    var currentColorBeingTouched: Colors!
    var colorArray: [Colors] = []
    var swipeUp = UISwipeGestureRecognizer()
    var timesSwiped: Int = 1
    var tutorialColor = CCBReader.load("ColorBox") as! Colors
    var secondTutorialColor = CCBReader.load("ColorBox") as! Colors
    weak var colorSpawnNode: CCNode!
    weak var highScoreLabel: CCLabelTTF!
    weak var scoreLabel: CCLabelTTF!
    weak var gameOverScore: CCLabelTTF!
    weak var swipesLeftIndicator: CCLabelTTF!
    weak var swipeUpLabel: CCLabelTTF!
    weak var slowMoAlreadyActivatedLabel: CCLabelTTF!
    weak var swipeTutorialLabel: CCLabelTTF!
    weak var notEnoughSwipesLabel: CCLabelTTF!
    weak var gameOverLabel: CCLabelTTF!
    weak var multiplierLabel: CCLabelTTF!
    weak var pausedMenu: CCScene!
    weak var pausedButton: CCButton!
    weak var restartButton: CCButton!
    weak var continueButton: CCButton!
    weak var earnSwipesButton: CCButton!
    weak var highScoreButton: CCButton!
    weak var homeButton: CCButton!
    
    // BOOLEANS
    var playingTutorial: Bool = false
    var thisIsTheFirstGame: Bool = false
    var userAlreadyDraggedSecondColor: Bool = false
    var userAlreadyDraggedFirstColor: Bool = false
    var difficultyDidChange: Bool = false
    var pausedbuttonPressed: Bool = false
    var gameoverLabelFell: Bool = false
    var gameover: Bool = false
    var swipesTutorialAlreadyShowedForCurrentGame: Bool = false
    var alreadySetSecondTutorialColor: Bool = false
    
    
    
    var distanceBetweenColors: CCTime = 1 {
        didSet {
            if !slowMoActivated {
                unschedule("spawnColors")
                schedule("spawnColors", interval: distanceBetweenColors)
            }
        }
    }
    var slowMoActivated: Bool = false {
        didSet {
            if slowMoActivated {
                unschedule("spawnColors")
                colorSpeed = 4
                distanceBetweenColors = 0.9
                schedule("spawnColors", interval: distanceBetweenColors)
                for color in colorArray {
                    color.stopAllActions()
                    color.move(colorSpeed, screenHeight: -CCDirector.sharedDirector().viewSize().height)
                }
                let delay = CCActionDelay(duration: 6)
                let setSlowMoToFalse = CCActionCallBlock(block: {self.slowMoActivated = false})
                runAction(CCActionSequence(array: [delay, setSlowMoToFalse]))
            } else if !slowMoActivated {
                updateDifficulty()
            }
        }
    }
    
    var swipesLeft = GameStateSingleton.sharedInstance.swipesLeft {
        didSet {
            animationManager.runAnimationsForSequenceNamed("Slow Mo Label")
            
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
            gameOverScore.string = NSLocalizedString("score", comment: "") + String(" \(score)")
            if !slowMoActivated {
                updateDifficulty()
            }
            if score > GameStateSingleton.sharedInstance.highscore {
                GameStateSingleton.sharedInstance.highscore = score
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenter(GameStateSingleton.sharedInstance.highscore)
                highScoreLabel.string = String("High Score: \(GameStateSingleton.sharedInstance.highscore)")
            }
        }
    }
    
    
    // Generates a random color
    func randomColor() -> CCColor {
        var ikeysColor: CCColor!
        let rand = arc4random_uniform(5)
        if rand == 0 {
            ikeysColor = CCColor(ccColor3b: ccColor3B(r: 255, g: 214, b: 75))
        } else if rand == 1 {
            ikeysColor = CCColor(ccColor3b: ccColor3B(r: 96, g: 211, b: 148))
        } else if rand == 2 {
            ikeysColor = CCColor(ccColor3b: ccColor3B(r: 164, g: 101, b: 173))
        } else if rand == 3 {
            ikeysColor = CCColor(ccColor3b: ccColor3B(r: 9, g: 77, b: 146))
        } else if rand == 4 {
            ikeysColor = CCColor(ccColor3b: ccColor3B(r: 239, g: 130, b: 117))
        }
        return ikeysColor
    }
    
    // Generate random x position for the colors
    func randomX() -> CGFloat {
        var xPosition: CGFloat!
        let randomNumber = arc4random_uniform(5)
        let width = CCDirector.sharedDirector().viewSize().width
        let widthOffset = width / 10
        if randomNumber == 0 {
            xPosition = widthOffset
        } else if randomNumber == 1 {
            xPosition = (width / 5) + widthOffset
        } else if randomNumber == 2 {
            xPosition = (2 * (width / 5)) + widthOffset
        } else if randomNumber == 3 {
            xPosition = (3 * (width / 5)) + widthOffset
        } else if randomNumber == 4 {
            xPosition = (4 * (width / 5)) + widthOffset
        }
        
        return xPosition
    }
    // creates new colors
    func spawnColors() {
        if !playingTutorial {
            if !gameover {
                let nextColor = CCBReader.load("ColorBox") as! Colors
                nextColor.colorNode.color = randomColor()
                colorArray.append(nextColor)
                colorSpawnNode.addChild(nextColor)
                nextColor.position = ccp(randomX(), CCDirector.sharedDirector().viewSize().height)
                nextColor.move(colorSpeed, screenHeight: -CCDirector.sharedDirector().viewSize().height)
            }
        }
    }
    override func onEnter() {
        super.onEnter()
        let kChartboostAppID = "55e2b3170d60252dd5a3b10d";
        let kChartboostAppSignature = "f9fdd445ee21890d8d8871519ad32899a1f3d527";
        Chartboost.startWithAppId(kChartboostAppID, appSignature: kChartboostAppSignature, delegate: self);
        Chartboost.cacheInterstitial(CBLocationGameOver)
        Chartboost.cacheMoreApps(CBLocationGameOver)
        Chartboost.cacheRewardedVideo(CBLocationGameOver)
    }
    
    func didLoadFromCCB() {
        // FOR THE FIRST TIME A PLAYER PLAYS THE GAME
        if !GameStateSingleton.sharedInstance.alreadyLoaded {
            GameStateSingleton.sharedInstance.soundeffectsEnabled = true
            GameStateSingleton.sharedInstance.backgroundMusicEnabled = true
            GameStateSingleton.sharedInstance.swipesLeft = 4
            GameStateSingleton.sharedInstance.shouldPlayTutorial = true
            thisIsTheFirstGame = true
            GameStateSingleton.sharedInstance.alreadyLoaded = true
        } else if !GameStateSingleton.sharedInstance.shouldPlayTutorial {
            playingTutorial = false
        }
        // LOCALIZE ALL LABELS FOR DIFFERENT LANGUAGES
        highScoreLabel.string = NSLocalizedString("highScore_Label", comment: "") + String(" \(GameStateSingleton.sharedInstance.highscore)")
        swipeTutorialLabel.string = NSLocalizedString("swipeTutorial", comment: "")
        continueButton.title = NSLocalizedString("continue", comment: "")
        restartButton.title = NSLocalizedString("restart", comment: "")
        gameOverLabel.string = NSLocalizedString("gameover", comment: "")
        gameOverScore.string = NSLocalizedString("score", comment: "") + String(" \(score)")
        highScoreButton.title = NSLocalizedString("highscores", comment: "")
        homeButton.title = NSLocalizedString("home", comment: "")
        
        // SHOW ADS AND SET INITIAL GAMEPLAY PROPERTIES
        if !iAdHandler.sharedInstance.isBannerDisplaying {
            iAdHandler.sharedInstance.loadAds(bannerPosition: .Bottom)
        }
        userInteractionEnabled = true
        swipesLeftIndicator.string = "Swipes Left: \(swipesLeft)"
        schedule("spawnColors", interval: CCTime(distanceBetweenColors))
        
        // ALLOW PLAYERS TO LISTEN TO THEIR OWN MUSIC
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        if GameStateSingleton.sharedInstance.backgroundMusicEnabled {
            audio.playBg("A Journey Awaits.mp3", loop: true)
        }
        
        if GameStateSingleton.sharedInstance.shouldPlayTutorial {
            sendTutorialColor()
            playingTutorial = true
        }
        swipesLeftIndicator.string = "Swipes Left: \(GameStateSingleton.sharedInstance.swipesLeft)"
        setupSwipeGesture()
    }
    
    override func update(delta: CCTime) {
        for color in colorArray {
            if color.position.y < (CCDirector.sharedDirector().viewSize().height / 100) * 12 {
                checkForColor(color)
                color.removeFromParent()
                colorArray.removeAtIndex(colorArray.indexOf(color)!)
            }
        }
        
        if gameover {
            swipesLeftIndicator.visible = true
            swipesLeftIndicator.opacity = 1
            userInteractionEnabled = false
            restartButton.visible = true
            pausedButton.visible = false
            scoreLabel.visible = false
            for color in colorArray {
                color.removeFromParent()
            }
            
            if !gameoverLabelFell {
                CCDirector.sharedDirector().view.removeGestureRecognizer(swipeUp)
                unschedule("spawnColors")
                animationManager.runAnimationsForSequenceNamed("Game Over")
                let takePicture = CCActionCallBlock(block: {GameStateSingleton.sharedInstance.screenShot = self.takeScreenshot()})
                let delay = CCActionDelay(duration: 1)
                runAction(CCActionSequence(array: [delay, takePicture]))
                if GameStateSingleton.sharedInstance.amountOfGamesPlayed >= 7 && !GameStateSingleton.sharedInstance.alreadyWroteReview {
                    askToRateGame()
                    GameStateSingleton.sharedInstance.amountOfGamesPlayed = 0
                } else {
                    Chartboost.showInterstitial(CBLocationGameOver)
                    GameStateSingleton.sharedInstance.amountOfGamesPlayed++
                }
                if !Chartboost.hasRewardedVideo(CBLocationGameOver) {
                    earnSwipesButton.visible = false
                }
                gameoverLabelFell = true
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        currentTouchLocation = touch.locationInWorld()
        for color in colorArray {
            if  Int(abs(touch.locationInWorld().x - color.position.x)) < 70 && Int(abs(touch.locationInWorld().y - color.position.y)) < 50 || CGRectContainsPoint(color.boundingBox(), currentTouchLocation) {
                currentColorBeingTouched = color
                currentColorBeingTouched.scale = 1.1
            }
        }
        
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if currentColorBeingTouched != nil {
            currentColorBeingTouched.position.x = touch.locationInWorld().x
            if currentColorBeingTouched.position.y <= (CCDirector.sharedDirector().viewSize().height / 100) * 12 {
                gameover = true
            }
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if currentColorBeingTouched != nil {
            repositionColor(currentColorBeingTouched)
            currentColorBeingTouched.scale = 1
            if effectsAreEnabled() {
                audio.playEffect("popSoundEffect.mp3")
            }
            if playingTutorial {
                if currentColorBeingTouched == tutorialColor {
                    userAlreadyDraggedFirstColor = true
                    if tutorialColor.position.x == screenWidthPercent * 70 {
                        animationManager.runAnimationsForSequenceNamed("Default Timeline")
                        tutorialColor.stopAllActions()
                        tutorialColor.move(4, screenHeight: -CCDirector.sharedDirector().viewSize().height)
                        if !alreadySetSecondTutorialColor {
                            sendSecondTutorialColor()
                        }
                    }
                } else if currentColorBeingTouched == secondTutorialColor {
                    userAlreadyDraggedSecondColor = true
                    if secondTutorialColor.position.x == screenWidthPercent * 30 {
                        animationManager.runAnimationsForSequenceNamed("Default Timeline")
                        secondTutorialColor.stopAllActions()
                        secondTutorialColor.move(4, screenHeight: -CCDirector.sharedDirector().viewSize().height)
                        playingTutorial = false
                        if thisIsTheFirstGame {
                            GameStateSingleton.sharedInstance.shouldPlayTutorial = false
                        }
                    }
                }
            }
            currentColorBeingTouched = nil
        }
    }
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if currentColorBeingTouched != nil {
            repositionColor(currentColorBeingTouched)
            if effectsAreEnabled() {
                audio.playEffect("popSoundEffect.mp3")
            }
            currentColorBeingTouched.scale = 1
            currentColorBeingTouched = nil
        }
    }
    // Move loose colors into set columns and blink the opacity of those columns for a second
    func repositionColor(color: Colors) {
        if color.position.x <= screenWidthPercent * 20 {
            color.position.x = screenWidthPercent * 10
            changeOpacity(yellowColumn)
        } else if color.position.x <= (screenWidthPercent * 40) && color.position.y > (screenWidthPercent * 20) {
            changeOpacity(greenColumn)
            color.position.x = screenWidthPercent * 30
        } else if color.position.x < (screenWidthPercent * 60) && color.position.y > (screenWidthPercent * 40) {
            changeOpacity(purpleColumn)
            color.position.x = screenWidthPercent * 50
        } else if color.position.x < (screenWidthPercent * 80) && color.position.y >= (screenWidthPercent * 60) {
            changeOpacity(blueColumn)
            color.position.x = screenWidthPercent * 70
        } else if color.position.x >= screenWidthPercent * 80 {
            changeOpacity(pinkColumn)
            color.position.x = screenWidthPercent * 90
        } else {
            // Sometimes when colors are near the blue column the reposition doesn't work so here's the (bad) solution.
            changeOpacity(blueColumn)
            color.position.x = screenWidthPercent * 70
        }
        
        
    }
    // Change opacity of columns when colors are dropped in them
    func changeOpacity(colornode: CCNodeColor) {
        colornode.opacity = 0.9
        let delay = CCActionDelay(duration: CCTime(0.15))
        let callblock = CCActionCallBlock(block: {colornode.opacity = 0.75})
        runAction(CCActionSequence(array: [delay, callblock]))
    }
    // Checks to see if the colors match the column they're in, if not, gameover; if so, add a point to score.
    func checkForColor(currentColor: Colors) {
        if currentColor.position.x == screenWidthPercent * 10 {
            if currentColor.colorNode.color != CCColor(ccColor3b: ccColor3B(r: 255, g: 214, b: 75)) {
                gameover = true
            } else {
                score++
            }
        }
        if currentColor.position.x == screenWidthPercent * 30 {
            if currentColor.colorNode.color != CCColor(ccColor3b: ccColor3B(r: 96, g: 211, b: 148)) {
                gameover = true
            } else {
                score++
            }
        }
        if currentColor.position.x == screenWidthPercent * 50 {
            if currentColor.colorNode.color != CCColor(ccColor3b: ccColor3B(r: 164, g: 101, b: 173)) {
                gameover = true
            } else {
                score++
            }
        }
        if currentColor.position.x == screenWidthPercent * 70 {
            if currentColor.colorNode.color != CCColor(ccColor3b: ccColor3B(r: 9, g: 77, b: 146)) {
                gameover = true
            } else {
                score++
            }
        }
        if currentColor.position.x == screenWidthPercent * 90 {
            if currentColor.colorNode.color != CCColor(ccColor3b: ccColor3B(r: 239, g: 130, b: 117)) {
                gameover = true
            } else {
                score++
            }
        }
    }
    
    // Update difficulty
    func updateDifficulty() {
        if score < 10 {
            colorSpeed = 4
            distanceBetweenColors = 1
        } else if score < 20 && score >= 10 {
            colorSpeed = 3.7
            distanceBetweenColors = 0.9
        } else if score < 30 && score >= 20 {
            colorSpeed = 3.4
            distanceBetweenColors = 0.8
        } else if score < 40 && score >= 30 {
            colorSpeed = 3.1
            distanceBetweenColors = 0.7
        } else if score < 50 && score >= 40 {
            colorSpeed = 2.8
            distanceBetweenColors = 0.6
        } else if score < 60 && score >= 50 {
            colorSpeed = 2.5
            distanceBetweenColors = 0.5
            goThroughSwipesTutorial()
        } else if score < 80 && score >= 60 {
            colorSpeed = 2.2
            distanceBetweenColors = 0.4
        } else if score < 100 && score >= 80 {
            colorSpeed = 2
            distanceBetweenColors = 0.4
        } else if score < 120 && score >= 100 {
            colorSpeed = 1.9
            distanceBetweenColors = 0.37
        } else if score < 140 && score >= 120 {
            colorSpeed = 1.75
            distanceBetweenColors = 0.34
        } else if score < 160 && score >= 140 {
            colorSpeed = 1.6
            distanceBetweenColors = 0.31
        } else if score < 180 && score >= 160 {
            colorSpeed = 1.5
            distanceBetweenColors = 0.285
        } else if score >= 180 {
            colorSpeed = 1.45
            distanceBetweenColors = 0.25
        }
    }
    // Checks if sound effects are enabled
    func effectsAreEnabled() -> Bool {
        if GameStateSingleton.sharedInstance.soundeffectsEnabled {
            return true
        }
        return false
    }
    // Sets up our swipe up gesture
    func setupSwipeGesture() {
        swipeUp = UISwipeGestureRecognizer(target: self, action: "activateSlowMo")
        swipeUp.direction = .Up
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeUp)
    }
    func activateSlowMo() {
        if !gameover {
            if !paused {
                if !playingTutorial {
                    swipeUpLabel.visible = false
                    if !slowMoActivated {
                        if GameStateSingleton.sharedInstance.swipesLeft >= timesSwiped {
                            slowMoActivated = true
                            animationManager.runAnimationsForSequenceNamed("Slow Mo Label")
                        } else {
                            notEnoughSwipesLabel.visible = true
                            let delay = CCActionDelay(duration: 2)
                            let callblock = CCActionCallBlock(block: {self.notEnoughSwipesLabel.visible = false})
                            runAction(CCActionSequence(array: [delay, callblock]))
                        }
                    } else {
                        slowMoAlreadyActivatedLabel.visible = true
                        let delay = CCActionDelay(duration: 2)
                        let callblock = CCActionCallBlock(block: {self.slowMoAlreadyActivatedLabel.visible = false})
                        runAction(CCActionSequence(array: [delay, callblock]))
                    }
                }
            }
        }
    }
    
    
    func takeScreenshot() -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        
        let width = Int32(CCDirector.sharedDirector().viewSize().width)
        let height = Int32(CCDirector.sharedDirector().viewSize().height)
        let renderTexture: CCRenderTexture = CCRenderTexture(width: width, height: height)
        
        renderTexture.begin()
        CCDirector.sharedDirector().runningScene.visit()
        renderTexture.end()
        
        return renderTexture.getUIImage()
    }
    
    // TUTORIAL
    func sendTutorialColor() {
        tutorialColor.colorNode.color = CCColor(ccColor3b: ccColor3B(r: 9, g: 77, b: 146))
        colorSpawnNode.addChild(tutorialColor)
        colorArray.append(tutorialColor)
        tutorialColor.position = ccp(screenWidthPercent * 30, CCDirector.sharedDirector().viewSize().height)
        tutorialColor.move(2, screenHeight: -CCDirector.sharedDirector().viewSize().height / 2)
        
        let delay = CCActionDelay(duration: 2.3)
        let callblock = CCActionCallBlock(block: {self.showFirstColorsHand()})
        runAction(CCActionSequence(array: [delay, callblock]))
        
    }
    func showFirstColorsHand() {
        if !userAlreadyDraggedFirstColor {
            animationManager.runAnimationsForSequenceNamed("First Color Hand")
        }
    }
    func sendSecondTutorialColor() {
        alreadySetSecondTutorialColor = true
        secondTutorialColor.colorNode.color = CCColor(ccColor3b: ccColor3B(r: 96, g: 211, b: 148))
        colorSpawnNode.addChild(secondTutorialColor)
        colorArray.append(secondTutorialColor)
        secondTutorialColor.position = ccp(screenWidthPercent * 90, CCDirector.sharedDirector().viewSize().height)
        secondTutorialColor.move(2, screenHeight: -CCDirector.sharedDirector().viewSize().height / 2)
        
        if !userAlreadyDraggedSecondColor {
            let delay = CCActionDelay(duration: 2.3)
            let callblock = CCActionCallBlock(block: {self.showSecondColorsHand()})
            runAction(CCActionSequence(array: [delay, callblock]))
        }
    }
    func showSecondColorsHand() {
        if !userAlreadyDraggedSecondColor && !gameover {
            animationManager.runAnimationsForSequenceNamed("Second Color Hand")
        }
    }
    // SWIPES TUTORIAL
    func showHowSwipesWork() {
        paused = true
        swipeTutorialLabel.visible = true
        continueButton.visible = true
        userInteractionEnabled = false
        pausedButton.userInteractionEnabled = false
    }
    // THIS IS THE FUNCTION THAT WILL RUN WHEN SCORE REACHES 50
    func goThroughSwipesTutorial() {
        if !GameStateSingleton.sharedInstance.swipeUpLabelWasShown {
            showHowSwipesWork()
            GameStateSingleton.sharedInstance.swipeUpLabelWasShown = true
        } else if GameStateSingleton.sharedInstance.shouldPlayTutorial && !swipesTutorialAlreadyShowedForCurrentGame {
            showHowSwipesWork()
            swipesTutorialAlreadyShowedForCurrentGame = true
        }
    }
    // ALERT USER TO RATE COLOR SORTER
    func askToRateGame() {
        let alertTitle = NSLocalizedString("alertTitle", comment: "")
        let alertMessage = NSLocalizedString("alertMessage", comment: "")
        let alertCancel = NSLocalizedString("alertCancel", comment: "")
        let sure = NSLocalizedString("sure", comment: "")
        let alert: UIAlertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancel)
        alert.addButtonWithTitle(sure)
        alert.show()
    }
    
    
    // BUTTONS
    func continueGame() {
        paused = false
        swipeTutorialLabel.visible = false
        continueButton.visible = false
        userInteractionEnabled = true
        pausedButton.userInteractionEnabled = true
    }
    func restart() {
        CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("Gameplay"))
    }
    func pause() {
        if pausedButton.selected {
            paused = false
            pausedMenu.visible = false
            pausedButton.selected = false
            userInteractionEnabled = true
            if GameStateSingleton.sharedInstance.backgroundMusicEnabled {
                audio.paused = false
            }
        } else if !pausedButton.selected {
            paused = true
            pausedMenu.visible = true
            pausedButton.selected = true
            userInteractionEnabled = false
            audio.paused = true
        }
    }
    func home() {
        CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("MainScene"))
        audio.stopBg()
    }
    func showStore() {
        audio.stopBg()
        if Chartboost.hasRewardedVideo(CBLocationGameOver) {
            Chartboost.showRewardedVideo(CBLocationGameOver)
            Chartboost.cacheRewardedVideo(CBLocationGameOver)
            GameStateSingleton.sharedInstance.swipesLeft += 1
            swipesLeftIndicator.string = String("Swipes Left: \(GameStateSingleton.sharedInstance.swipesLeft)")
        } else {
            let alert = UIAlertView()
            alert.title = "OH NO!!"
            alert.message = "Looks like the ads could not load!"
            alert.addButtonWithTitle("That sucks")
            alert.show()
        }
    //    CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("Store"))
    }
    
    
    // CALLBACKS
    func decreaseAmountOfSwipes() {
        if GameStateSingleton.sharedInstance.swipesLeft >= timesSwiped {
            GameStateSingleton.sharedInstance.swipesLeft -= timesSwiped
            timesSwiped += 1
            swipesLeftIndicator.string = "Swipes Left: \(GameStateSingleton.sharedInstance.swipesLeft)"
            multiplierLabel.string = "Multiplier: \(timesSwiped)x"
        }
    }
    func didFailToLoadInterstitial(location: String!, withError error: CBLoadError) {
        Chartboost.showMoreApps(CBLocationGameOver)
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        let title: NSString = alertView.buttonTitleAtIndex(buttonIndex)!
        let sureString = NSLocalizedString("sure", comment: "")
        if title.isEqualToString(sureString) {
            if let url = NSURL(string: "https://appsto.re/us/PVxC9.i") {
                UIApplication.sharedApplication().openURL(url)
                GameStateSingleton.sharedInstance.alreadyWroteReview = true
            }
        }
    }
    
    
}

// GAMECENTER
extension Gameplay: GKGameCenterControllerDelegate {
    func showLeaderboard() {
        let viewController = CCDirector.sharedDirector().parentViewController!
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
        audio.stopBg()
    }
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
}

//extension Gameplay: BannerDelegate {
//    func bannerLoaded() {
//        iAdHandler.sharedInstance.displayBannerAd()
//        print("yes")
//    }
//}







