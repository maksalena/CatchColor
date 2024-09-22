//
//  StartScreenViewController.swift
//  CatchColor
//
//  Created by Алёна Максимова on 23.09.2024.
//

import UIKit

class StartScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

        // Add title label
        let titleLabel = UILabel()
        titleLabel.text = "Catch Colors"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Constraints for title label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200)
        ])

        // Add start button
        let startButton = UIButton(type: .custom)
        startButton.setImage(UIImage(named: "main_start"), for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        // Constraints for start button
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            startButton.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    @objc func startGame() {
        // Navigate to the level selection screen
        let levelSelectionVC = LevelSelectionViewController()
        navigationController?.pushViewController(levelSelectionVC, animated: true)
    }
}

