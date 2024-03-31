//
//  SeeMoreCommentsCell.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/3/31.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class SeeMoreCommentsCell: UITableViewCell {
    var onSeeMoreTapped: (() -> Void)? // 添加一個閉包作為回調

    let seeMoreButton = UIButton(type: .system) // 創建一個按鈕

    override func awakeFromNib() {
        super.awakeFromNib()
        // 按鈕初始化設置
        seeMoreButton.setTitle("看更多評論", for: .normal)
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonAction), for: .touchUpInside)
        contentView.addSubview(seeMoreButton)
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seeMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            seeMoreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc func seeMoreButtonAction() {
        onSeeMoreTapped?() // 當按鈕被點擊，調用閉包
    }
}

