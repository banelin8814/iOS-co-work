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
    var starsViews = [UIImageView]()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = .darkGray
        
        commentLabel.font = .systemFont(ofSize: 18)
        commentLabel.textColor = .darkGray
        commentLabel.numberOfLines = 0
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(commentLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            commentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        setupStars()
    }
    
    // 將星星按照迴圈依序排列
    private func setupStars() {
        // 清除舊的星星 view
        starsViews.forEach { $0.removeFromSuperview() }
        starsViews.removeAll()

        // 創建並新增新的星星 view
        for _ in 0..<Constants.starsCount {
            let star = makeStarIcon()
            starsViews.append(star)
            contentView.addSubview(star)
            star.translatesAutoresizingMaskIntoConstraints = false
        }

        // 設置星星的layout
            for (index, starView) in starsViews.enumerated() {
                let leftAnchor = index == 0 ? nameLabel.leadingAnchor : starsViews[index - 1].trailingAnchor
                NSLayoutConstraint.activate([
                    starView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 8),
                    starView.leadingAnchor.constraint(equalTo: leftAnchor, constant: index == 0 ? 0 : 5),
                    starView.heightAnchor.constraint(equalToConstant: 20),
                    starView.widthAnchor.constraint(equalTo: starView.heightAnchor)
                ])
                
                // 新增最後一顆星星的底部 layout
                if index == Constants.starsCount - 1 {
                    NSLayoutConstraint.activate([
                        starView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
                    ])
                }
            }
        }
    
    // 創造實心和空心的星星
    private func makeStarIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "icon_unfilled_star"), highlightedImage: UIImage(named: "icon_filled_star"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    // 根據 rating 更新星星的顯示狀態
    func updateStars(rating: Int) {
        setupStars()
        // enumerated() 提供每個元素的 index 和 value
        for (index, starView) in starsViews.enumerated() {
            // 如果星星的 index 小於傳入的 rating，則設為實心星星；如果 rating 是 3，則前三個星星是實心
            starView.isHighlighted = index < rating
        }
    }
    
    func configureCell(with comment: CommentForm) {
           nameLabel.text = comment.name
           commentLabel.text = comment.comment
           updateStars(rating: comment.rate)
       }
    
    // MARK: - Constants
    
    private struct Constants {
        static let starsCount: Int = 5
        static let sendButtonHeight: CGFloat = 50
        static let containerHorizontalInsets: CGFloat = 30
        static let starContainerHeight: CGFloat = 40
    }
}
