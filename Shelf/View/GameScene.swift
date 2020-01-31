//
//  GameScene.swift
//  Shelf
//
//  Created by Nathan Konrad on 12/1/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    func makeBackground(_ imageName: String, isFirstTime : Bool = false) {
        var duration: TimeInterval = 18
        if isFirstTime == true {
            duration = 10
        }
        let backgroundTexture = SKTexture(imageNamed: imageName)
        let backgroundTextureHeight = backgroundTexture.size().height
        
        let screenHeight = UIScreen.main.bounds.height
        let delta = backgroundTextureHeight - screenHeight
        let destY = backgroundTextureHeight * 1.5 - delta
        let originY = backgroundTextureHeight * 0.5 - delta
        let originY2 = backgroundTextureHeight * -0.5 - delta
        
        /**
         * Scroll up current background that is visible on screen
         */
        self.physicsBody?.affectedByGravity = false
        let shiftBackground = SKAction.moveTo(y: destY, duration: duration)
        if isFirstTime == true {
            shiftBackground.timingMode = .easeIn
        }
        let replaceBackground = SKAction.moveTo(y: originY , duration: 0)
        let movingAndReplacingBackground = SKAction.repeatForever(SKAction.sequence([shiftBackground, replaceBackground]))
        let background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: UIScreen.main.bounds.midX, y: originY  )
        background.size.width = self.frame.width
        background.run(movingAndReplacingBackground)
        self.addChild(background)
        
        /**
         * Scroll up another background that is not visible on screen
         * where the top is the bottom of the current background
         */
        let shiftBackground2 = SKAction.moveTo(y: originY, duration: duration)
        if isFirstTime == true {
            shiftBackground2.timingMode = .easeIn
        }
        let replaceBackground2 = SKAction.moveTo(y: originY2, duration: 0)
        let movingAndReplacingBackground2 = SKAction.repeatForever(SKAction.sequence([shiftBackground2, replaceBackground2]))
        let background2 = SKSpriteNode(texture: backgroundTexture)
        background2.position = CGPoint(x: UIScreen.main.bounds.midX, y: originY2)
        background2.size.width = self.frame.width
        background2.run(movingAndReplacingBackground2)
        
        self.addChild(background2)
    }
}
