//
//  Colors.swift
//  ColorSort
//
//  Created by Ikey Benzaken on 8/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Colors: CCNode {
    weak var colorNode: CCNodeColor!
    
    func move(speed: CCTime, screenHeight: CGFloat) {
        var move: CCActionMoveBy!
        move = CCActionMoveBy(duration: speed, position: ccp(0, screenHeight))
        runAction(move)
    }
}