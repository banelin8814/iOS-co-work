//
//  UserCommentTableViewCell.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/3/30.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class UserCommentTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let commentLabel = UILabel()
    let starsContainer = UIStackView()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Private methods
    
    private func createStars() {
        /// 收集用戶的評分
        for index in 1...Constants.starsCount {
            let star = makeStarIcon()
            star.tag = index
            starsContainer.addArrangedSubview(star)
        }
    }
    
    private func makeStarIcon() -> UIImageView {
        /// 設計星等的 UI
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_unfilled_star"), highlightedImage: #imageLiteral(resourceName: "icon_filled_star"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }
    
    private func setupUI() {
        // 設定 nameLabel 的屬性
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = .darkGray
        
        // 設定 starsContainer 的屬性
        starsContainer.axis = .horizontal
        starsContainer.distribution = .fillEqually
        starsContainer.spacing = 5
        
        // 設定 commentLabel 的屬性
        commentLabel.font = .systemFont(ofSize: 18)
        commentLabel.textColor = .darkGray
        commentLabel.numberOfLines = 0
        
        // 添加元件到 contentView
        contentView.addSubview(nameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(starsContainer)
        
        // 呼叫下面的配置方法
        setupConstraints()
        createStars()
    }
    
    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            commentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            starsContainer.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 8),
            starsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starsContainer.heightAnchor.constraint(equalToConstant: 20),
            starsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

    }
    
    func updateStars(rating: Int) {
        createStars() // 確保星星有新增
        for starView in starsContainer.arrangedSubviews {
            if let star = starView as? UIImageView {
                let starIndex = starsContainer.arrangedSubviews.firstIndex(of: starView)! + 1
                star.isHighlighted = starIndex <= rating
            }
        }
    }
    
    // MARK: - Constants {
    
    private struct Constants {
        static let starsCount: Int = 5
        
        static let sendButtonHeight: CGFloat = 50
        static let containerHorizontalInsets: CGFloat = 30
        static let starContainerHeight: CGFloat = 40
    }
}

