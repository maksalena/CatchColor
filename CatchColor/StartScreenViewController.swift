//
//  StartScreenViewController.swift
//  CatchColor
//
//  Created by Алёна Максимова on 23.09.2024.
//

import UIKit

class StartScreenViewController: UIViewController {
    
    private var menuOverlayView: UIView?
    var soundButton = UIButton()
    var isSoundEnabled: Bool {
        set {
            return UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
        } get {
            UserDefaults.standard.bool(forKey: "isSoundEnabled")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    print("ssc")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "logo")
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImage)

        // Constraints for title label
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            logoImage.widthAnchor.constraint(equalToConstant: 300),
            logoImage.heightAnchor.constraint(equalToConstant: 150)
        ])

        // Add start button
        let startButton = UIButton()
        startButton.setBackgroundImage(UIImage(named: "main_start"), for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Courier-Bold", size: 32)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        // Constraints for start button
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 60),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Add menu button below the start button
        let menuButton = UIButton()
        menuButton.setBackgroundImage(UIImage(named: "menu_icon"), for: .normal)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setTitle("Settings", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.titleLabel?.font = UIFont(name: "Courier-Bold", size: 32)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        view.addSubview(menuButton)
        
        // Constraints for menu button
        NSLayoutConstraint.activate([
            menuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            menuButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 30),
            menuButton.widthAnchor.constraint(equalToConstant: 200),
            menuButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc func startGame() {
        // Navigate to the level selection screen
        let levelSelectionVC = LevelSelectionViewController()
        levelSelectionVC.isSoundEnabled = self.isSoundEnabled
        navigationController?.pushViewController(levelSelectionVC, animated: true)
    }
    
    @objc func menuButtonTapped() {
        // Create an overlay view with the "pause-background"
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Constraints for the overlay view
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add the "pause-background" image
        let pauseBackgroundImageView = UIImageView(image: UIImage(named: "pause-background"))
        pauseBackgroundImageView.contentMode = .scaleAspectFill
        pauseBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(pauseBackgroundImageView)
        
        // Constraints for pause-background image view
        NSLayoutConstraint.activate([
            pauseBackgroundImageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            pauseBackgroundImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            pauseBackgroundImageView.widthAnchor.constraint(equalToConstant: 230),
            pauseBackgroundImageView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // Add label "Menu" on top of pause-background
        let menuLabel = UILabel()
        menuLabel.text = "Settings"
        menuLabel.font = UIFont(name: "Courier", size: 28)
        menuLabel.textColor = .white
        menuLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(menuLabel)
        
        // Constraints for the Menu label
        NSLayoutConstraint.activate([
            menuLabel.centerXAnchor.constraint(equalTo: pauseBackgroundImageView.centerXAnchor),
            menuLabel.topAnchor.constraint(equalTo: pauseBackgroundImageView.topAnchor, constant: 30)
        ])
        
        // Add button with background image "sound_on_icon"
        soundButton = UIButton(type: .custom)
        soundButton.setImage(UIImage(named: isSoundEnabled ? "sound_on_icon" : "sound_off_icon"), for: .normal)
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        overlayView.addSubview(soundButton)
        
        // Constraints for sound button
        NSLayoutConstraint.activate([
            soundButton.centerXAnchor.constraint(equalTo: pauseBackgroundImageView.centerXAnchor),
            soundButton.topAnchor.constraint(equalTo: menuLabel.bottomAnchor, constant: 30),
            soundButton.widthAnchor.constraint(equalToConstant: 50),
            soundButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let okButton = UIButton()
        okButton.setBackgroundImage(UIImage(named: "ok_icon"), for: .normal)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "Courier", size: 20)
        okButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        overlayView.addSubview(okButton)
        
        // Constraints for sound button
        NSLayoutConstraint.activate([
            okButton.centerXAnchor.constraint(equalTo: pauseBackgroundImageView.centerXAnchor),
            okButton.topAnchor.constraint(equalTo: soundButton.bottomAnchor, constant: 30),
            okButton.widthAnchor.constraint(equalToConstant: 80),
            okButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Store overlayView so we can remove it later
        self.menuOverlayView = overlayView
    }
    
    @objc func dismissMenu() {
        menuOverlayView?.isHidden = true
    }
    
    @objc func toggleSound() {
        isSoundEnabled.toggle()
        
        soundButton.setImage(UIImage(named: isSoundEnabled ? "sound_on_icon" : "sound_off_icon"), for: .normal)
    }
}
