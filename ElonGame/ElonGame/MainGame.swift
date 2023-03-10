//
//  GameScene.swift
//  ElonGame
//
//  Created by Николай Ногин on 01.01.2023.
//

import SpriteKit
import GameplayKit

class MainGame: SKScene {
    
    // Nodes
    var player: SKNode?
    var joystick: SKNode?
    var joystickKnob: SKNode?
    var cameraNode: SKCameraNode?
    var mountains1: SKNode?
    var mountain2: SKNode?
    var mountains3: SKNode?
    var mountains4: SKNode?

    var moon: SKNode?
    var stars: SKNode?
    
    // Bools
    var joystickAction = false
    var rewardIsNotTouched = true
    var isHit = false
    var immortal = false
    
    // Measure
    var knobRadius: CGFloat = 50
    
    // Score
    var scoreLabel = SKLabelNode()
    var score = 0
    
    // Hearts
    var heartsArray = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    // Sprite Engine
    var previousTimeInterval: TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 5.0
    
    // Player state
    var playerStateMachine: GKStateMachine!
    
    // Animation names
    let meteorAnimation = "meteor_animation"
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
//        let soundAction = SKAction.repeatForever(SKAction.playSoundFileNamed("backgroundMusic.wav", waitForCompletion: false))
//        run(soundAction)
        
        player = self.childNode(withName: "playerNode")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        mountains1 = childNode(withName: "mountains1")
        mountain2 = childNode(withName: "mountain2")
        mountains3 = childNode(withName: "mountains3")
        mountains4 = childNode(withName: "mountains4")
        moon = childNode(withName: "lunaNode")
        stars = childNode(withName: "starsBackground")
        
        playerStateMachine = GKStateMachine(states: [
            JumpingState(playerNode: player!),
            WalkingState(playerNode: player!),
            IdleState(playerNode: player!),
            LandingState(playerNode: player!),
            StunnedState(playerNode: player!)
        ])
        
        playerStateMachine.enter(IdleState.self)
        
        // Hearts
        heartContainer.position = CGPoint(x: -300, y: 140)
        heartContainer.zPosition = 5
        cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        // Timer
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.spawnMeteor()
        }
        
        // Position label
        scoreLabel.position = CGPoint(x: (cameraNode?.position.x)! + 310, y: 140)
        scoreLabel.fontColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        scoreLabel.fontSize = 24
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = String(score)
        cameraNode?.addChild(scoreLabel)
    }
}


// MARK: Touches
extension MainGame {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(JumpingState.self)
                run(Sound.jump.action)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        
        if !joystickAction { return }
        
        // Distance
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 500.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
        }
    }
}


// MARK: Action
extension MainGame {
    
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
    
    func rewardTouch() {
        score += 1
        scoreLabel.text = String(score)
    }
    
    func fillHearts(count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.xScale = 0.1
            heart.yScale = 0.1
            let xPosition = (heart.size.width + 8) * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heartsArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    func loseHeart() {
        if isHit == true && !immortal {
            immortal = true
            let lastElementIndex = heartsArray.count - 1
            if heartsArray.indices.contains(lastElementIndex - 1) {
                let lastHeart = heartsArray[lastElementIndex]
                lastHeart.removeFromParent()
                heartsArray.remove(at: lastElementIndex)
                
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                    self.isHit = false
                    self.immortal = false
                }
            }
            else {
                dying()
                showDieScene()
            }
        }
    }

    
    func dying() {
        let dieAction = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1)
        player?.run(dieAction)
        self.removeAllActions()
        fillHearts(count: 3)
    }
    
    func showDieScene() {
        let gameOverScene = SKScene(fileNamed: "GameOverScene")
        gameOverScene?.scaleMode = .aspectFit
        self.view?.presentScene(gameOverScene)
    }
}


// MARK: Game Loop
extension MainGame {
    override func update(_ currentTime: TimeInterval) {

        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        rewardIsNotTouched = true
        
        // Camera
        cameraNode?.position.x = player!.position.x
        joystick?.position.y = (cameraNode?.position.y)! - 82
        joystick?.position.x = (cameraNode?.position.x)! - 296
        
        
        // Player movement
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
        let positivePosition = xPosition < 0 ? -xPosition : xPosition

        if floor(positivePosition) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction: SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        
        if movingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -4.6, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        }
        else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 4.6, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
            
        }
        else {
            faceAction = move
        }
        player?.run(faceAction)
        
        // Background Parallax Animations
        let parallaxMountains1Animation = SKAction.moveTo(x: (player?.position.x)!/(-10), duration: 0.0)
        mountains1?.run(parallaxMountains1Animation)
        
        let parallaxMountain2Animation = SKAction.moveTo(x: (player?.position.x)!/(-20), duration: 0.0)
        mountain2?.run(parallaxMountain2Animation)
        
        let parallaxMountains3Animation = SKAction.moveTo(x: (player?.position.x)!/(-40), duration: 0.0)
        mountains3?.run(parallaxMountains3Animation)
        
        let parallaxMountains4Animation = SKAction.moveTo(x: (player?.position.x)!/(-50), duration: 0.0)
        mountains4?.run(parallaxMountains4Animation)
        
        let parallaxMoonAnimation = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        moon?.run(parallaxMoonAnimation)
        
        let parallaxStarsAnimation = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        stars?.run(parallaxStarsAnimation)
        
    }
}

// MARK: Collisions
extension MainGame: SKPhysicsContactDelegate {
    
    struct Collision {
        
        enum Masks: Int {
            case killing, player, reward, ground
            var bitmask: UInt32 { return 1 << self.rawValue}
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches (_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) || (first.bitmask == masks.second && second.bitmask == masks.first)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            isHit = true
            
            run(Sound.hit.action)
            
            loseHeart()
            playerStateMachine.enter(StunnedState.self)
    
            if contact.bodyB.node?.name == "Meteor" {
                contact.bodyB.node?.removeFromParent()
            }
            
            if contact.bodyA.node?.name == "Meteor" {
                contact.bodyA.node?.removeFromParent()
            }
        }
        
        if collision.matches(.player, .ground) {
            playerStateMachine.enter(LandingState.self)
        }
        
        if (collision.matches(.player, .reward)) {
            if contact.bodyA.node?.name != "playerNode" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0
                contact.bodyA.node?.removeFromParent()
            }
            else if contact.bodyB.node?.name != "playerNode" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0
                contact.bodyB.node?.removeFromParent()
            }
            
            if rewardIsNotTouched {
                rewardTouch()
                rewardIsNotTouched = false
            }
            
            run(Sound.reward.action)
        }
        
        if collision.matches(.ground, .killing) {
            if contact.bodyA.node?.name == "Meteor", let meteor = contact.bodyA.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            
            if contact.bodyB.node?.name == "Meteor", let meteor = contact.bodyB.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            
            run(Sound.meteorFalling.action)
        }
    }
}


// MARK: Meteor
extension MainGame {
    func spawnMeteor() {
        let node = SKSpriteNode(imageNamed: "meteor/1")
        
        node.name = "Meteor"
        let cameraPosition = Int((self.cameraNode?.position.x)!)
        let randomX = Int.random(in: cameraPosition - 450...cameraPosition + 450)

        node.position = CGPoint(x: randomX, y: 270)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.4)
        node.zPosition = 5
        node.xScale = 0.3
        node.yScale = 0.3
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 30)
        node.physicsBody = physicsBody
        
        physicsBody.categoryBitMask = Collision.Masks.killing.bitmask
        physicsBody.collisionBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physicsBody.contactTestBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        physicsBody.fieldBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.restitution = 0.2
        physicsBody.friction = 10
        
        // Meteor animation
        let textures: Array <SKTexture> = (2...11).map({ return "meteor/\($0)" }).map(SKTexture.init)

        lazy var action = {
            SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.08))
        }()
                
        node.run(action, withKey: meteorAnimation)
        
        addChild(node)
        
    }
    
    func createMolten(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "molten")
        node.position.x = position.x
        node.position.y = position.y - 46
        node.zPosition = 4
        node.xScale = 0.68
        node.yScale = 0.46
        node.colorBlendFactor = 0.2
        
        addChild(node)
        
        let action = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        
        node.run(action)
    }
}
