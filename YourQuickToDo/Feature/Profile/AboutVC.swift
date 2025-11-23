//
//  AboutVC.swift
//  YourQuickToDo
//
//  About page with app information and support option
//

import UIKit

class AboutVC: AppUtilityBaseClass {
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppTheme.Colors.primary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Use the same icon as launch screen
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium)
        imageView.image = UIImage(systemName: "chart.line.text.clipboard.fill", withConfiguration: config)
        
        return imageView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "YourQuickToDo"
        label.font = AppTheme.Fonts.title1()
        label.textColor = AppTheme.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 1.0.0"
        label.font = AppTheme.Fonts.body()
        label.textColor = AppTheme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        YourQuickToDo is built to make your daily planning simple, clear, and stress-free. Thank you for using the app and being part of this journey!
        
        If you enjoy using it and want to support future updates, you can buy me a coffee ☕️
        """
        label.font = AppTheme.Fonts.body()
        label.textColor = AppTheme.Colors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var supportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("☕️ Buy Me a Coffee", for: .normal)
        button.titleLabel?.font = AppTheme.Fonts.headline()
        button.backgroundColor = AppTheme.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSupportButton), for: .touchUpInside)
        
        // Add shadow for depth
        button.layer.shadowColor = AppTheme.Colors.primary.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        
        return button
    }()
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Made with ❤️ by Kundan"
        label.font = AppTheme.Fonts.caption()
        label.textColor = AppTheme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    /// router 
    private let router: ProfileRouter
    // Dependecies Injector DI
    init(router: ProfileRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "About"
        view.backgroundColor = .systemBackground
        
        // Add views
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(appIconImageView)
        contentView.addSubview(appNameLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(supportButton)
        contentView.addSubview(footerLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // App Icon
            appIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            appIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 100),
            appIconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // App Name
            appNameLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 24),
            appNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Version
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 32),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            // Support Button
            supportButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            supportButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            supportButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            supportButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Footer
            footerLabel.topAnchor.constraint(equalTo: supportButton.bottomAnchor, constant: 40),
            footerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            footerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapSupportButton() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Navigate to Buy Me a Coffee page
        let buyMeCoffeeVC = BuyMyCoffeeWebViewVC()
        let navController = UINavigationController(rootViewController: buyMeCoffeeVC)
        navController.modalPresentationStyle = .pageSheet
        
        // Configure sheet appearance for iOS 15+
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
}
