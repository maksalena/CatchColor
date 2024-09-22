//
//  GameViewController.swift
//  CatchColor
//
//  Created by Алёна Максимова on 22.09.2024.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var selectedLevel: Int = 1  // Default to level 1

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Create the GameScene and pass the selected level to it
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.selectedLevel = selectedLevel // Pass the selected level

            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
