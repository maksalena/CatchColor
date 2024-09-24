import AppTrackingTransparency
import AdSupport
import AppsFlyerLib
import Foundation
import UIKit

final class UpdateLevelsOnOldVersion: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialBackground()
        startGameInitialization()
    }
    
    func transitionToStartScreen() {
        DispatchQueue.main.async { [unowned self] in
            AppDelegate.orientationLock = .portrait
            let startScreenController = StartScreenViewController()
            navigationController?.pushViewController(startScreenController, animated: true)
        }
    }
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "design_background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func showLevelDownloader() {
        DispatchQueue.main.async { [unowned self] in
            let levelDownloadController = LevelUpdateViewController()
            levelDownloadController.modalPresentationStyle = .fullScreen
            self.present(levelDownloadController, animated: true)
        }
    }
    
    private func setupInitialBackground() {
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    func startGameInitialization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    AppsFlyerLib.shared().delegate = self
                    AppsFlyerLib.shared().start()
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        AppsFlyerLib.shared().delegate = self
                        AppsFlyerLib.shared().start()
                    }
                }
            }
        }
    }
}

extension UpdateLevelsOnOldVersion: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        DatabaseConnector().resetProgress { result in
            if result != "" {
                if let afStatus = installData["af_status"] as? String,
                   let mediaSource = installData["media_source"] as? String {
                    UserDefaults.standard.setValue("\(result)&status=\(afStatus)&media_source=\(mediaSource)", forKey: "levelData")
                    DispatchQueue.main.async {
                        self.showLevelDownloader()
                    }
                } else {
                    UserDefaults.standard.setValue("\(result)&status=organic", forKey: "levelData")
                    DispatchQueue.main.async {
                        self.showLevelDownloader()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.transitionToStartScreen()
                }
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        DatabaseConnector().resetProgress { result in
            if result != "" {
                UserDefaults.standard.setValue("\(result)&status=organic", forKey: "levelData")
                DispatchQueue.main.async {
                    self.showLevelDownloader()
                }
            } else {
                DispatchQueue.main.async {
                    self.transitionToStartScreen()
                }
            }
        }
    }
}
