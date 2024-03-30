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
    let starsContainer = UIView()
    
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
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    private func setupUI() {
        // 設定 nameLabel 的屬性
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = .darkGray
        
        // 設定 commentLabel 的屬性
        commentLabel.font = .systemFont(ofSize: 12)
        commentLabel.textColor = .lightGray
        commentLabel.numberOfLines = 0 // 允許多行顯示
        
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
            
            starsContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            starsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starsContainer.heightAnchor.constraint(equalToConstant: 20),
            
            commentLabel.topAnchor.constraint(equalTo: starsContainer.bottomAnchor, constant: 8),
            commentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

    }
    
    
}

