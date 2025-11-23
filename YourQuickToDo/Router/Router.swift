//
//  Router.swift
//  YourQuickToDo
//
//  Generic Router Pattern for UIKit Navigation
//  Adapted from SwiftUI NavigationPath approach
//

import UIKit

// MARK: - Navigation Destination Protocol

/// Protocol that defines a navigation destination
/// Similar to SwiftUI's NavigationDestination but adapted for UIKit
protocol NavigationDestination {
    /// Title for the navigation bar
    var title: String { get }
    
    /// Creates and returns the view controller for this destination
    func createViewController() -> UIViewController
}

// MARK: - Generic Router Class

/// Generic Router class for type-safe navigation
/// Usage: Create a Router<YourFlow> where YourFlow conforms to NavigationDestination
class Router<Destination: NavigationDestination> {
    
    // MARK: - Properties
    
    /// Weak reference to the navigation controller
    weak var navigationController: UINavigationController?
    
    /// Navigation stack to track destinations (similar to SwiftUI's navPaths)
    private(set) var navPaths: [Destination] = []
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to a destination by pushing onto the navigation stack
    /// - Parameters:
    ///   - destination: The destination to navigate to
    ///   - animated: Whether to animate the transition (default: true)
    func navigate(to destination: Destination, animated: Bool = true) {
        guard let navigationController = navigationController else {
            print("⚠️ Router: Navigation controller is nil")
            return
        }
        
        let viewController = destination.createViewController()
        viewController.title = destination.title
        
        navPaths.append(destination)
        navigationController.pushViewController(viewController, animated: animated)
        
        print("✅ Router: Navigated to \(destination.title)")
    }
    
    /// Navigate back by popping the top view controller
    /// - Parameter animated: Whether to animate the transition (default: true)
    func navigateBack(animated: Bool = true) {
        guard let navigationController = navigationController else {
            print("⚠️ Router: Navigation controller is nil")
            return
        }
        
        guard !navPaths.isEmpty else {
            print("⚠️ Router: Navigation stack is empty")
            return
        }
        
        navPaths.removeLast()
        navigationController.popViewController(animated: animated)
        
        print("✅ Router: Navigated back")
    }
    
    /// Navigate to root by popping all view controllers
    /// - Parameter animated: Whether to animate the transition (default: true)
    func navigateToRoot(animated: Bool = true) {
        guard let navigationController = navigationController else {
            print("⚠️ Router: Navigation controller is nil")
            return
        }
        
        let count = navPaths.count
        navPaths.removeAll()
        navigationController.popToRootViewController(animated: animated)
        
        print("✅ Router: Navigated to root (removed \(count) destinations)")
    }
    
    /// Present a destination modally
    /// - Parameters:
    ///   - destination: The destination to present
    ///   - animated: Whether to animate the transition (default: true)
    ///   - modalPresentationStyle: The presentation style (default: .automatic)
    ///   - completion: Optional completion handler
    func present(_ destination: Destination,
                 animated: Bool = true,
                 modalPresentationStyle: UIModalPresentationStyle = .automatic,
                 completion: (() -> Void)? = nil) {
        guard let navigationController = navigationController else {
            print("⚠️ Router: Navigation controller is nil")
            return
        }
        
        let viewController = destination.createViewController()
        viewController.title = destination.title
        viewController.modalPresentationStyle = modalPresentationStyle
        
        navigationController.present(viewController, animated: animated, completion: completion)
        
        print("✅ Router: Presented \(destination.title)")
    }
    
    /// Dismiss the currently presented view controller
    /// - Parameters:
    ///   - animated: Whether to animate the transition (default: true)
    ///   - completion: Optional completion handler
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = navigationController else {
            print("⚠️ Router: Navigation controller is nil")
            return
        }
        
        navigationController.dismiss(animated: animated, completion: completion)
        
        print("✅ Router: Dismissed presented view controller")
    }
    
    /// Set the navigation controller for this router
    /// - Parameter navigationController: The navigation controller to use
    func setNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - Router Extensions

extension Router {
    /// Check if the navigation stack is empty
    var isEmpty: Bool {
        return navPaths.isEmpty
    }
    
    /// Get the current navigation depth
    var depth: Int {
        return navPaths.count
    }
    
    /// Clear the navigation stack without popping view controllers
    /// Useful for resetting state
    func clearStack() {
        navPaths.removeAll()
        print("✅ Router: Cleared navigation stack")
    }
}
