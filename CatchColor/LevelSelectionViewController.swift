//
//  LevelSelectionViewController.swift
//  CatchColor
//
//  Created by Алёна Максимова on 23.09.2024.
//

import UIKit
import SpriteKit

class LevelSelectionViewController: UIViewController {
    
    var isSoundEnabled: Bool {
        set {
            return UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
        } get {
            UserDefaults.standard.bool(forKey: "isSoundEnabled")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 1
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            // Custom animation for smooth transition
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 0 // Fade out
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set default value for highest level if it doesn't exist
        if UserDefaults.standard.integer(forKey: "highestLevel") == 0 {
            UserDefaults.standard.set(1, forKey: "highestLevel")
        }
    }
    
    private let unlockLabel: UILabel = {
        let label = UILabel()
        label.text = "To unlock the new level score 100 points"
        label.textAlignment = .center
        label.font = UIFont(name: "Courier", size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
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
        
        view.addSubview(unlockLabel)
        
        unlockLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unlockLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unlockLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            unlockLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            unlockLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
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
            gridStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 170)
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
                    outgoing.font = UIFont(name: "Courier", size: 20)
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
            configureLevelButtons(gridStackView: gridStackView)
        }
    }
    
    func configureLevelButtons(gridStackView: UIStackView) {
        // Clear any existing buttons
        for subview in gridStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        // Create level buttons (4 per row, 12 in total)
        for row in 0..<3 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 35 // Increase spacing to prevent overlap
            
            for col in 1...4 {
                let level = row * 4 + col
                let levelButton = UIButton(type: .custom)
                
                // Check if the level is accessible
                let isLevelAccessible = level <= LevelManager.loadHighestLevel()
                
                // Use UIButton.Configuration for button layout and design
                var config = UIButton.Configuration.plain()
                config.image = UIImage(named: "level")?.resized(to: CGSize(width: 60, height: 60))
                config.title = "\(level)"
                config.baseForegroundColor = isLevelAccessible ? .white : .gray
                config.imagePlacement = .top
                config.contentInsets = .zero
                config.titleAlignment = .center
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont(name: "Courier", size: 22)
                    return outgoing
                }
                
                levelButton.configuration = config
                levelButton.tag = level
                levelButton.isUserInteractionEnabled = isLevelAccessible
                levelButton.addTarget(self, action: #selector(selectLevel), for: .touchUpInside)
                
                rowStackView.addArrangedSubview(levelButton)
            }
            gridStackView.addArrangedSubview(rowStackView)
        }
    }

    @objc func selectLevel(sender: UIButton) {
        guard sender.isEnabled else { return }
        let gameVC = GameViewController()
        gameVC.selectedLevel = sender.tag
        gameVC.isSoundEnabled = self.isSoundEnabled
        
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
