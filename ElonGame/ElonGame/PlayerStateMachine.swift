//
//  PlayerStateMachine.swift
//  ElonGame
//
//  Created by Николай Ногин on 08.01.2023.
//

import Foundation
import GameplayKit

fileprivate let characterAnimationKey = "Sprite Animation"

class PlayerState: GKState {
    unowned var playerNode: SKNode
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
        
        super.init()
    }
}

class JumpingState: PlayerState {
    var hasFinishedJumping: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {

        if stateClass is StunnedState.Type {
            return true
        }
    
        if hasFinishedJumping && stateClass is LandingState.Type {
            return true
        }
        
        if hasFinishedJumping && stateClass is IdleState.Type {
            return true
        }

        return false
    }
    
    let textures = SKTexture(imageNamed: "player/9")
    lazy var action = {
        SKAction.animate(with: [textures], timePerFrame: 0.1)
    }()

    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        
        hasFinishedJumping = false
        playerNode.run(.applyForce(CGVector(dx: 0, dy: 205), duration: 0.15))
        
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { timer in
            self.hasFinishedJumping = true
        }
    }
}

class LandingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type:
            return false
        default:
            return true
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(IdleState.self)
    }
}

class IdleState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is IdleState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures: Array <SKTexture> = [
        SKTexture(imageNamed: "player/8" ),
        SKTexture(imageNamed: "player/0" )
    ]
    lazy var action = {
        SKAction.repeatForever(.animate(with: textures, timePerFrame: 6.1))
    }()
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class WalkingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is WalkingState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures: Array <SKTexture> = (2...8).map({ return "player/\($0)" }).map(SKTexture.init)
    lazy var action = {
        SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))
    }()
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class StunnedState: PlayerState {
    var isStunned: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if isStunned { return false }
        
        switch stateClass {
        case is IdleState.Type:
            return true
        default:
            return false
        }
    }
    
    let action = SKAction.repeat(.sequence([
        .fadeAlpha(by: 0.5, duration: 0.01),
        .wait(forDuration: 0.20),
        .fadeAlpha(to: 0.5, duration: 0.01),
        .wait(forDuration: 0.20),
        .fadeAlpha(to: 1, duration: 0.01),
    ]), count: 5)
    
    override func didEnter(from previousState: GKState?) {
        isStunned = true
        playerNode.run(action)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.isStunned = false
            self.stateMachine?.enter(IdleState.self)
            
            
        }
    }
}
