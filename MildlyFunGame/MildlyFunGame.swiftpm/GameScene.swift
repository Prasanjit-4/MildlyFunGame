import SpriteKit
import PlaygroundSupport
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    private var currentPath: UIBezierPath?
    private var currentLine: SKShapeNode?
    private var ball: SKShapeNode?
    private var isDrawingEnabled = true
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var fallSoundPlayer: AVAudioPlayer?
    private var collectSoundPlayer: AVAudioPlayer?
    private var scoreLabel: SKLabelNode!
    private var score = 0
    private var moveForce: CGFloat = 500.0
    private var totalCollectibles = 5
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupGround()
        setupControls()
        setupScoreLabel()
        spawnCollectibles()
        playBackgroundMusic()
        setupBackButton()
        setupHelpButton()
    }
    
    private func showSticker(at position: CGPoint, this stickerName: String) {
        let sticker = SKSpriteNode(imageNamed: stickerName) // Replace "sticker" with your actual sticker image name
        sticker.position = position
        if stickerName == "monke" {
            sticker.setScale(0.5)
        }
        else{
            sticker.setScale(0.2)
        }
       
        addChild(sticker)
        
        // Balloon-like movement
        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -10...10), y: 50, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveUp, fadeOut, remove])
        
        sticker.run(sequence)
    }
    
    private func setupHelpButton() {
        let helpButton = createButton(text: "❓", position: CGPoint(x: size.width - 50, y: size.height - 50), name: "help")
        helpButton.fontSize = 30
        addChild(helpButton)
    }
    
    private func showHelpPopup() {
        let popup = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 10)
        popup.fillColor = SKColor.white
        popup.strokeColor = SKColor.black
        popup.position = CGPoint(x: size.width / 2, y: size.height / 2)
        popup.name = "popup"
        
        let instructions = "Draw a path to guide the ball.\nCollect coins for points.\nUse buttons to move the ball."
        let label = SKLabelNode(text: instructions)
        label.fontSize = 18
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 20)
        label.numberOfLines = 3
        label.preferredMaxLayoutWidth = 280
        popup.addChild(label)
        
        let closeButton = createButton(text: "✖️", position: CGPoint(x: 0, y: -70), name: "closePopup")
        closeButton.fontSize = 30
        popup.addChild(closeButton)
        
        addChild(popup)
    }
    
    private func hideHelpPopup() {
        childNode(withName: "popup")?.removeFromParent()
    }
    
    private func showWinPopup() {
        let popup = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 10)
        popup.fillColor = SKColor.white
        popup.strokeColor = SKColor.black
        popup.position = CGPoint(x: size.width / 2, y: size.height / 2)
        popup.name = "winPopup"
        
        let label = SKLabelNode(text: "Well Done! 🎉")
        label.fontSize = 24
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 20)
        popup.addChild(label)
        
        addChild(popup)
        
        // Automatically clear the track after 2 seconds
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { self.clearTrack() }
        ]))
    }
    
    
    
    private func setupBackButton() {
        let backButton = createButton(text: "MENU", position: CGPoint(x: 50, y: 50), name: "back")
        backButton.fontSize = 30
        addChild(backButton)
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width - 100, y: 50)
        addChild(scoreLabel)
    }
    
    // MARK: - Sound Methods
    private func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "Guligulislowed", withExtension: "wav") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.5
                backgroundMusicPlayer?.play()
            } catch {
                print("Error loading background music: \(error)")
            }
        }
    }
    
    private func playFallSound() {
        if let soundURL = Bundle.main.url(forResource: "fallsound", withExtension: "wav") {
            do {
                fallSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                fallSoundPlayer?.volume = 1.0
                fallSoundPlayer?.play()
            } catch {
                print("Error loading fall sound: \(error)")
            }
        }
    }
    
    private func playCollectSound() {
        if let soundURL = Bundle.main.url(forResource: "collect", withExtension: "wav") {
            do {
                collectSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                collectSoundPlayer?.volume = 1.0
                collectSoundPlayer?.play()

            } catch {
                print("Error loading collect sound: \(error)")
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupGround() {
        let ground = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0),
                                  size: CGSize(width: size.width, height: 20))
        ground.position = CGPoint(x: size.width / 2, y: 10)
        
        // Add a subtle gradient overlay
        let gradientNode = SKSpriteNode(color: .white, size: CGSize(width: ground.size.width, height: 2))
        gradientNode.alpha = 0.2
        gradientNode.position = CGPoint(x: 0, y: ground.size.height - 2)
        ground.addChild(gradientNode)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = 1
        ground.physicsBody?.contactTestBitMask = 2
        ground.name = "ground"
        addChild(ground)
    }
    
    private func setupBall(at position: CGPoint) {
        ball = SKShapeNode(circleOfRadius: 20)
        ball?.fillColor = SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        ball?.strokeColor = SKColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
        ball?.lineWidth = 2.0
        ball?.position = position
        
        // Add a subtle gradient effect
        let gradientNode = SKShapeNode(circleOfRadius: 15)
        gradientNode.fillColor = SKColor.white
        gradientNode.strokeColor = .clear
        gradientNode.alpha = 0.2
        gradientNode.position = CGPoint(x: -5, y: 5)
        ball?.addChild(gradientNode)
        
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.physicsBody?.affectedByGravity = true
        ball?.physicsBody?.friction = 0.5
        ball?.physicsBody?.restitution = 0.2
        ball?.physicsBody?.allowsRotation = true
        ball?.physicsBody?.categoryBitMask = 2
        ball?.physicsBody?.contactTestBitMask = 1 | 3
        addChild(ball!)
        isDrawingEnabled = false
    }
    
    private func setupControls() {
        let leftButton = createButton(text: "⬅️", position: CGPoint(x: size.width / 4, y: 50), name: "left")
        let rightButton = createButton(text: "➡️", position: CGPoint(x: size.width / 2, y: 50), name: "right")
        let clearButton = createButton(text: "🔄", position: CGPoint(x: 3 * size.width / 4, y: 50), name: "clear")
        
        addChild(leftButton)
        addChild(rightButton)
        addChild(clearButton)
    }
    
    private func spawnCollectibles() {
        for _ in 0..<5 {
            let collectible = SKShapeNode(circleOfRadius: 10)
            collectible.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1.0)
            collectible.strokeColor = SKColor(red: 0.9, green: 0.75, blue: 0.0, alpha: 1.0)
            collectible.lineWidth = 1.0
            
            // Add shine effect
            let shineNode = SKShapeNode(circleOfRadius: 7)
            shineNode.fillColor = .white
            shineNode.strokeColor = .clear
            shineNode.alpha = 0.3
            shineNode.position = CGPoint(x: -2, y: 2)
            collectible.addChild(shineNode)
            
            let randomX = CGFloat.random(in: 50...size.width - 50)
            let randomY = CGFloat.random(in: size.height / 3...size.height - 100)
            collectible.position = CGPoint(x: randomX, y: randomY)
            
            collectible.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            collectible.physicsBody?.isDynamic = false
            collectible.physicsBody?.categoryBitMask = 3
            collectible.physicsBody?.contactTestBitMask = 2
            collectible.name = "collectible"
            
            // Add subtle pulsing animation
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
            let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
            let pulse = SKAction.repeatForever(pulseSequence)
            collectible.run(pulse)
            
            addChild(collectible)
        }
    }
    
    private func createButton(text: String, position: CGPoint, name: String) -> SKLabelNode {
        let button = SKLabelNode(fontNamed: "AvenirNext-Bold")
        button.text = text
        button.fontSize = 40
        button.fontColor = .white
        button.position = position
        button.name = name
        return button
    }
    
    private func clearTrack() {
        removeAllChildren()
        setupGround()
        setupControls()
        setupScoreLabel()
        spawnCollectibles()
        ball = nil
        isDrawingEnabled = true
        score = 0
        updateScore()
        setupBackButton()
        setupHelpButton()
    }
    
    private func updateScore() {
        scoreLabel.text = "Score: \(score)"
        let remainingCollectibles = children.filter { $0.name == "collectible" }.count
        if score >= 50 || remainingCollectibles == 0 {
            showWinPopup()
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "back" {
                if let view = view {
                    let entryScene = EntryScene(size: size)
                    entryScene.scaleMode = .aspectFill
                    view.presentScene(entryScene, transition: SKTransition.fade(withDuration: 0.5))
                }
                return
            } else if node.name == "left" {
                ball?.physicsBody?.applyForce(CGVector(dx: -moveForce, dy: 0))
                return
            } else if node.name == "right" {
                ball?.physicsBody?.applyForce(CGVector(dx: moveForce, dy: 0))
                return
            } else if node.name == "clear" {
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 1.0),
                    SKAction.run { self.clearTrack() }
                ]))
                return
            } else if node.name == "help" {
                showHelpPopup()
                return
            } else if node.name == "closePopup" {
                hideHelpPopup()
                return
            }
        }
        
        guard isDrawingEnabled else { return }
        
        currentPath = UIBezierPath()
        currentPath?.move(to: location)
        
        currentLine = SKShapeNode()
        currentLine?.strokeColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.8)
        currentLine?.lineWidth = 4
        currentLine?.lineCap = .round
        addChild(currentLine!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let path = currentPath, isDrawingEnabled else { return }
        let location = touch.location(in: self)
        path.addLine(to: location)
        currentLine?.path = path.cgPath
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let path = currentPath, isDrawingEnabled else { return }
        
        let pathNode = SKShapeNode(path: path.cgPath)
        pathNode.strokeColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.8)
        pathNode.lineWidth = 4
        pathNode.lineCap = .round
        pathNode.physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
        pathNode.physicsBody?.friction = 0.5
        pathNode.physicsBody?.contactTestBitMask = 1
        addChild(pathNode)
        
        if ball == nil, let firstPoint = currentPath?.cgPath.boundingBox.origin {
            let adjustedY = firstPoint.y + currentPath!.cgPath.boundingBox.height
            setupBall(at: CGPoint(x: firstPoint.x + 5, y: adjustedY + 20))
        }
    }
    
    // MARK: - Physics Contact Detection
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        
        print("Collision detected: \(bodyA?.name ?? "nil") with \(bodyB?.name ?? "nil")")
        
        if bodyA?.name == "collectible" {
            showSticker(at: bodyA!.position, this: "penguin")
            bodyA?.removeFromParent()
            score += 10
            playCollectSound()
            updateScore()
        } else if bodyB?.name == "collectible" {
            showSticker(at: bodyB!.position ,this: "penguin")
            bodyB?.removeFromParent()
            score += 10
            playCollectSound()
            updateScore()
        }
        
        let bodyC = contact.bodyA.categoryBitMask
        let bodyD = contact.bodyB.categoryBitMask
        
        if (bodyC == 1 && bodyD == 2) || (bodyC == 2 && bodyD == 1) {
            let posA = contact.bodyA.node?.position ?? .zero
            let posB = contact.bodyB.node?.position ?? .zero
            let fallPosition = CGPoint(x: (posA.x + posB.x) / 2, y: (posA.y + posB.y) / 2)
            
            showSticker(at: fallPosition, this: "monke")
            playFallSound()
            run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { self.clearTrack() }
            ]))
        }
    }
}


