//
//  BuyMyCoffeeWebViewVC.swift
//  YourQuickToDo
//
//  Created by User on 22/11/25.
//

/*
import UIKit
import WebKit

class BuyMyCoffeeWebViewVC: UIViewController {
    
    // MARK: - Properties
    
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var activityIndicator: UIActivityIndicatorView!
    
    private let buyMeCoffeeURL = "https://buymeacoffee.com/kundaniosdev"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadBuyMeCoffeePage()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Support Developer"
        view.backgroundColor = .systemBackground
        
        // Add close button
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupWebView() {
        // Configure WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Progress view for loading indication
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = AppTheme.Colors.primary
        view.addSubview(progressView)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Observe loading progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func loadBuyMeCoffeePage() {
        guard let url = URL(string: buyMeCoffeeURL) else {
            showError(message: "Invalid URL")
            return
        }
        
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
        
        print("☕️ Loading Buy Me a Coffee: \(buyMeCoffeeURL)")
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        self.tabBarController?.selectedIndex = 0 
        dismiss(animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

// MARK: - WKNavigationDelegate

extension BuyMyCoffeeWebViewVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        progressView.isHidden = false
        print("☕️ Started loading...")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        progressView.isHidden = true
        print("✅ Buy Me a Coffee page loaded successfully")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        progressView.isHidden = true
        print("❌ Failed to load: \(error.localizedDescription)")
        showError(message: "Failed to load page. Please check your internet connection.")
    }
}
*/
