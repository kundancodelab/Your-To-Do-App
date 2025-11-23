//
//  AppTheme.swift
//  YourQuickToDo
//
//  Created by User on 23/11/25.
//

import UIKit

struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        /// Primary Brand Color - A vibrant, premium Indigo-Purple
        static let primary = UIColor(red: 0, green: 0, blue: 0, alpha: 1.00) // #5856D6
        
        /// Secondary Accent Color - A soft Teal for success/completion
        static let secondary = UIColor(red: 0.19, green: 0.82, blue: 0.76, alpha: 1.00) // #30D1C2
        
        /// Alert/Error Color - A warm Coral
        static let error = UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 1.00) // #FF6B6B
        
        /// Background Color - Adapts to Light/Dark mode
        static let background = UIColor.systemBackground
        
        /// Secondary Background - Slightly lighter/darker for cards/cells
        static let cardBackground = UIColor.secondarySystemBackground
        
        /// Primary Text Color
        static let textPrimary = UIColor.label
        
        /// Secondary Text Color
        static let textSecondary = UIColor.secondaryLabel
        
        /// White - Always white (for text on primary buttons)
        static let white = UIColor.white
    }
    
    // MARK: - Fonts
    struct Fonts {
        
        /// Large Title - 34pt Bold
        static func largeTitle() -> UIFont {
            return UIFont.systemFont(ofSize: 34, weight: .bold)
        }
        
        /// Title 1 - 28pt Bold
        static func title1() -> UIFont {
            return UIFont.systemFont(ofSize: 28, weight: .bold)
        }
        
        /// Title 2 - 22pt Semibold
        static func title2() -> UIFont {
            return UIFont.systemFont(ofSize: 22, weight: .semibold)
        }
        
        /// Headline - 17pt Semibold
        static func headline() -> UIFont {
            return UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        
        /// Body - 17pt Regular
        static func body() -> UIFont {
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        }
        
        /// Subheadline - 15pt Regular
        static func subheadline() -> UIFont {
            return UIFont.systemFont(ofSize: 15, weight: .regular)
        }
        
        /// Caption - 12pt Medium
        static func caption() -> UIFont {
            return UIFont.systemFont(ofSize: 12, weight: .medium)
        }
        
        /// Button Title - 18pt Bold
        static func buttonTitle() -> UIFont {
            return UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 12.0
        static let padding: CGFloat = 20.0
        static let buttonHeight: CGFloat = 50.0
    }
}
