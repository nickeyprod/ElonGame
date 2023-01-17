//
//  GameOver.swift
//  ElonGame
//
//  Created by Николай Ногин on 14.01.2023.
//

import Foundation
import SpriteKit

class GameOver: SKScene {
    override func sceneDidLoad() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            let level1 = MainGame(fileNamed: "Level1Scene")
            level1?.scaleMode = .aspectFit
            self.view?.presentScene(level1)
            self.removeAllActions()
        }
    }
}
