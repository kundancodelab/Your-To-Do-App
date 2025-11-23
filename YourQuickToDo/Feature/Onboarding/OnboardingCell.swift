//
//  OnboardingCell.swift
//  YourQuickToDo
//
//  Created by User on 23/11/25.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCell"
    
    private let slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(slideImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        titleLabel.font = AppTheme.Fonts.title1()
        titleLabel.textColor = AppTheme.Colors.textPrimary
        
        descriptionLabel.font = AppTheme.Fonts.body()
        descriptionLabel.textColor = AppTheme.Colors.textSecondary
        
        NSLayoutConstraint.activate([
            slideImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            slideImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            slideImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            slideImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            titleLabel.topAnchor.constraint(equalTo: slideImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])
    }
    
    func configure(with slide: OnboardingSlide) {
        let tintedImage = slide.image?.withRenderingMode(.alwaysTemplate)
        slideImageView.image = tintedImage
        slideImageView.tintColor = AppTheme.Colors.primary
        
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }

}
