//
//  OnloardingVC.swift
//  YourQuickToDo
//
//  Created by User on 23/11/25.
//

import UIKit

struct OnboardingSlide {
    let title: String
    let description: String
    let image: UIImage?
}

class OnloardingVC: UIViewController {

    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = AppTheme.Colors.background
        cv.delegate = self
        cv.dataSource = self
        cv.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = slides.count
        pc.currentPageIndicatorTintColor = AppTheme.Colors.primary
        pc.pageIndicatorTintColor = AppTheme.Colors.secondary.withAlphaComponent(0.3)
        pc.isUserInteractionEnabled = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.titleLabel?.font = AppTheme.Fonts.buttonTitle()
        btn.backgroundColor = AppTheme.Colors.primary
        btn.setTitleColor(AppTheme.Colors.white, for: .normal)
        btn.layer.cornerRadius = AppTheme.Layout.cornerRadius
        btn.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Properties
    
    private var slides: [OnboardingSlide] = []
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                actionButton.setTitle("Get Started", for: .normal)
            } else {
                actionButton.setTitle("Next", for: .normal)
            }
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 OnloardingVC: viewDidLoad")
        view.backgroundColor = .systemBackground
        
        setupSlides()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🚀 OnloardingVC: viewDidAppear - Frame: \(view.frame)")
    }
    
    // MARK: - Setup
    
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Manage Your Tasks", description: "Organize all your to-dos and projects in one place.", image: UIImage(systemName: "list.bullet.clipboard")),
            OnboardingSlide(title: "Stay on Track", description: "Set deadlines and reminders to never miss a thing.", image: UIImage(systemName: "clock.fill")),
            OnboardingSlide(title: "Achieve Goals", description: "Track your progress and reach your personal and professional goals.", image: UIImage(systemName: "star.fill"))
        ]
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        if currentPage == slides.count - 1 {
            navigateToHome()
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    private func navigateToHome() {
        // Mark onboarding as completed
        UserDefaults.standard.isOnboardingCompleted = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate TabBarController
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController else {
            print("❌ TabBar not found in storyboard")
            return
        }
        
        tabBarVC.selectedIndex = 0
        
        if let window = self.view.window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarVC
            })
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension OnloardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.identifier, for: indexPath) as? OnboardingCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: slides[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
