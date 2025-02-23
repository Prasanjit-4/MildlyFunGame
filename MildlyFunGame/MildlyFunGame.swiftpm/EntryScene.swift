import SpriteKit

class EntryScene: SKScene {
    override func didMove(to view: SKView) {
        // Create gradient background
        let gradientNode = SKSpriteNode(texture: createGradientTexture(size: size))
        gradientNode.size = size
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gradientNode)
        
        // Add title label with enhanced animation
        let titleLabel = SKLabelNode(text: "Mildly Fun Game")
        titleLabel.fontSize = 60
        titleLabel.fontColor = .white
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        titleLabel.alpha = 0
        addChild(titleLabel)
        
        // Add shadow to title
        let titleShadow = titleLabel.copy() as! SKLabelNode
        titleShadow.fontColor = UIColor.black.withAlphaComponent(0.3)
        titleShadow.position = CGPoint(x: titleLabel.position.x + 2, y: titleLabel.position.y - 2)
        titleShadow.alpha = 0
        addChild(titleShadow)
        
        // Animate title with bounce effect
        let bounceUp = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        titleLabel.run(bounceUp)
        titleShadow.run(bounceUp)
        
        // Create container for buttons
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(buttonContainer)
        
        // Add start button with modern styling
        let startButton = createButton(text: "Start Game", fontSize: 40, yOffset: 0)
        startButton.name = "start"
        buttonContainer.addChild(startButton)
        
        // Animate button appearing
        startButton.setScale(0.5)
        startButton.alpha = 0
        startButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
        ]))
    }
    
    // Function to create a button
    func createButton(text: String, fontSize: CGFloat, yOffset: CGFloat) -> SKLabelNode {
        let button = SKLabelNode(text: text)
        button.fontSize = fontSize
        button.fontColor = .white
        button.fontName = "AvenirNext-Bold"
        button.position = CGPoint(x: 0, y: yOffset)
        return button
    }
    
    // Function to generate gradient texture
    func createGradientTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [
                UIColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 1.0).cgColor,
                UIColor(red: 0.4, green: 0.1, blue: 0.8, alpha: 1.0).cgColor
            ]
            gradient.locations = [0.0, 1.0]
            gradient.render(in: context.cgContext)
        }
        
        return SKTexture(image: image)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        if let nodeName = nodes.first?.name, nodeName == "start" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 1))
        }
    }
}

