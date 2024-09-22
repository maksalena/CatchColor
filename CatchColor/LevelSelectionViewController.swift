//
//  LevelSelectionViewController.swift
//  CatchColor
//
//  Created by Алёна Максимова on 23.09.2024.
//

import UIKit
import SpriteKit

class LevelSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupUI()
    }
    
    func setupBackButton() {
        // Customize the back button appearance for the entire UINavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set the back button's text attributes (bold and colored)
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.white  // Change this to your desired color
        ]
        
        // Apply the appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    func setupUI() {
        // Set background image instead of solid color
        let backgroundImageView = UIImageView(image: UIImage(named: "background"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)  // Send it to the back to allow UI elements to be on top
        
        // Set the constraints for background image to fill the entire screen
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Create a grid of buttons for levels
        let gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 50
        gridStackView.alignment = .center
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridStackView)

        // Constraints for grid stack view
        NSLayoutConstraint.activate([
            gridStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200)
        ])

        // Define the size of the level buttons
        let buttonSize: CGFloat = 60  // Increased size for better touch interaction
        
        // Create level buttons (4 per row, 12 in total)
        for row in 0..<3 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 35  // Increase spacing to prevent overlap

            for col in 1...4 {
                let level = row * 4 + col
                let levelButton = UIButton(type: .custom)
                
                // Use UIButton.Configuration for button layout and design
                var config = UIButton.Configuration.plain()
                config.image = UIImage(named: "level")?.resized(to: CGSize(width: buttonSize, height: buttonSize))
                config.title = "\(level)"
                config.baseForegroundColor = .white
                config.imagePlacement = .top  // Place image above text
                config.contentInsets = .zero   // Ensure no extra padding
                config.titleAlignment = .center
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont.boldSystemFont(ofSize: 20)
                    return outgoing
                }
                
                levelButton.configuration = config
                levelButton.tag = level
                levelButton.addTarget(self, action: #selector(selectLevel), for: .touchUpInside)

                // Apply constraints for fixed button size
                levelButton.translatesAutoresizingMaskIntoConstraints = false
                levelButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
                levelButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true

                rowStackView.addArrangedSubview(levelButton)
            }
            gridStackView.addArrangedSubview(rowStackView)
        }
    }


    @objc func selectLevel(sender: UIButton) {
        let gameVC = GameViewController()
        
        if let view = gameVC.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            scene.selectedLevel = sender.tag
            view.presentScene(scene)
        }
        navigationController?.pushViewController(gameVC, animated: true)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
