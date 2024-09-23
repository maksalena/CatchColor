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
    var isSoundEnabled: Bool = true

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.gameSceneDelegate = self
            scene.scaleMode = .aspectFill
            scene.selectedLevel = selectedLevel // Передаем выбранный уровень
            scene.isSoundEnabled = isSoundEnabled // Передаем режим звука
            
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
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.popViewController(animated: true)
    }
}
