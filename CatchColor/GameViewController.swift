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

    var selectedLevel: Int = 1

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.gameSceneDelegate = self
            scene.scaleMode = .aspectFill
            scene.selectedLevel = selectedLevel // Передаем выбранный уровень
            
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

extension GameViewController: GameSceneDelegate {
    func didPressHomeButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
