//
//  Level1.swift
//  ElonGame
//
//  Created by Николай Ногин on 14.01.2023.
//

import Foundation
import SpriteKit

class Level1: MainGame {
    
    var startLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        startLabel.position = CGPoint(x: (cameraNode?.position.x)!, y: (cameraNode?.position.y)!)
        startLabel.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        startLabel.fontSize = 24
        startLabel.preferredMaxLayoutWidth = 780
        startLabel.numberOfLines = 0
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.horizontalAlignmentMode = .center
        startLabel.text = String("Собери 7 кристаллов для перехода на следующий уровень")
        cameraNode?.addChild(startLabel)
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            self.startLabel.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if score >= 7 {
            let nextLevel = MainGame(fileNamed: "Level2")
            nextLevel?.scaleMode = .aspectFit
            view?.presentScene(nextLevel)
            run(Sound.levelUp.action)
        }
    }
}
