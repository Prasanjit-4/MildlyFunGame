import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var isGameActive = true // Controls whether the game runs
    
    var scene: SKScene {
        let scene = EntryScene(size: CGSize(width: 800, height: 600))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        VStack {
            if isGameActive {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
               
            }
        }
    }
}

