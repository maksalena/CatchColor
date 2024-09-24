import Foundation
import UIKit
import WebKit
import Network

class LevelUpdateViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let networkAlert = UIAlertController(
        title: "Network Error",
        message: "Please connect to the internet to continue.",
        preferredStyle: .alert
    )
    
    private var webView: WKWebView?
    private var topConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOrientationAndView()
        setupWebView()
        monitorInternetConnection()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        adjustWebViewLayout()
    }
    
    private func configureOrientationAndView() {
        AppDelegate.orientationLock = .all
        view.backgroundColor = .black
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - WebView Setup
    
    private func setupWebView() {
        let webViewConfiguration = createWebViewConfig()
        webView = WKWebView(frame: view.bounds, configuration: webViewConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.isOpaque = false
        webView?.backgroundColor = .clear
        webView?.scrollView.isScrollEnabled = true
        
        guard let webView = webView else { return }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        topConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint?.isActive = true
        
        adjustWebViewLayout()
        loadWebViewContent()
    }
    
    private func createWebViewConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = [.all]
        }
        
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        return config
    }
    
    private func loadWebViewContent() {
        guard let urlString = UserDefaults.standard.string(forKey: "levelds"),
              let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    private func adjustWebViewLayout() {
        guard let webView = webView else { return }
        topConstraint?.isActive = false
        
        let isPortrait = preferredInterfaceOrientationForPresentation.isPortrait
        let isFullScreenDevice = (UIScreen.main.bounds.height / UIScreen.main.bounds.width) > 2
        let topInset: CGFloat = isFullScreenDevice ? (isPortrait ? 70 : 0) : 0
        
        topConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset)
        topConstraint?.isActive = true
        view.updateConstraintsIfNeeded()
    }
    
    // MARK: - Internet Connection Monitoring
    
    private func monitorInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] pathUpdate in
            DispatchQueue.main.async {
                if pathUpdate.status == .satisfied {
                    self?.dismissNetworkAlert()
                } else {
                    self?.presentNetworkAlert()
                }
            }
        }
        
        let queue = DispatchQueue(label: "InternetMonitorQueue")
        monitor.start(queue: queue)
    }
    
    private func presentNetworkAlert() {
        present(networkAlert, animated: true, completion: nil)
    }
    
    private func dismissNetworkAlert() {
        networkAlert.dismiss(animated: true, completion: nil)
    }
}

extension LevelUpdateViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
        popupWebView.uiDelegate = self
        view.addSubview(popupWebView)
        return popupWebView
    }
}

extension LevelUpdateViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed provisional navigation: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed navigation: \(error.localizedDescription)")
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
