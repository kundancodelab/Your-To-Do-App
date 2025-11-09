//
//  UIView+Extension.swift
//  YourQuickToDo
//
//  Created by User on 09/11/25.
//

import Foundation
import UIKit

extension UIView {
    /// Adds a gradient layer that automatically adjusts to Auto Layout constraints
    /// - Parameters:
    ///   - hexColors: Array of hex color strings (e.g., ["#FF0000", "#0000FF"])
    ///   - direction: Gradient direction (default: .vertical)
    ///   - cornerRadius: Corner radius for gradient layer (default: 0)
    func addAutoLayoutGradient(hexColors: [String],
                                opacities: [CGFloat]? = nil, // Optional opacity values
                                direction: GradientDirection = .vertical,
                                cornerRadius: CGFloat = 0) {
        
        // Convert hex strings to UIColor array
        let colors = hexColors.compactMap { UIColor(hex: $0) }
        
        // Ensure the opacity array matches the number of colors, otherwise default to full opacity
        let finalOpacities = opacities ?? Array(repeating: 1.0, count: hexColors.count)
        
        // Create gradient layer
        let gradient = CAGradientLayer()
        
        // Apply opacity to each color
        gradient.colors = zip(colors, finalOpacities).map { (color, opacity) in
            color.withAlphaComponent(opacity).cgColor
        }
        gradient.cornerRadius = cornerRadius
        
        // Set gradient direction
        switch direction {
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .diagonalTopToBottom:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .diagonalBottomToTop:
            gradient.startPoint = CGPoint(x: 1, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }
        
        // Remove any existing gradient layer
        removeGradient()
        
        // Insert gradient at the bottom
        self.layer.insertSublayer(gradient, at: 0)
        
        // Set up automatic resizing
        gradient.frame = self.bounds
        self.layoutIfNeeded()
        
        // Observe bounds changes
        let observer = self.observe(\.bounds, options: .new) { [weak self] (view, _) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if let gradientLayer = strongSelf.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
                    gradientLayer.frame = strongSelf.bounds
                }
            }
        }
        
        // Store observer
        objc_setAssociatedObject(self, &AssociatedKeys.gradientObserver, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    
    /// Removes gradient layer
    func removeGradient() {
        if let gradientLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        objc_setAssociatedObject(self, &AssociatedKeys.gradientObserver, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    // Apply animation...
    func animateWithFadeAndAction(duration: TimeInterval = 0.1,
                                      fadeAlpha: CGFloat = 0.5,
                                      action: @escaping () -> Void) {
           let originalAlpha = self.alpha
           
           UIView.animate(withDuration: duration, animations: {
               self.alpha = fadeAlpha
           }) { _ in
               UIView.animate(withDuration: duration, animations: {
                   self.alpha = originalAlpha
               }) { _ in
                   action()
               }
           }
       }
}

// Gradient direction enum
enum GradientDirection {
    case vertical
    case horizontal
    case diagonalTopToBottom
    case diagonalBottomToTop
}

// Hex color extension
extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 || hexString.count == 8 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        if hexString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }
    }
}

// Private association keys
private struct AssociatedKeys {
    static var gradientObserver: UInt8 = 0
}
