//
//  Sound.swift
//  ElonGame
//
//  Created by Николай Ногин on 16.01.2023.
//

import Foundation
import SpriteKit

enum Sound: String {
    case hit, jump, levelUp, meteorFalling, reward
    
    var action: SKAction {
        return SKAction.playSoundFileNamed(rawValue + "Sound.wav", waitForCompletion: false)
    }
}


extension SKAction {
    static let playGameMusic = SKAction.repeatForever(playSoundFileNamed("backgroundMusic.wav", waitForCompletion: false))
}
