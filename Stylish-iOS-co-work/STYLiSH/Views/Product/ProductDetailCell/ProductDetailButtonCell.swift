//
//  ProductDetailButtonCell.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/3/30.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class ProductDetailButtonCell: UITableViewCell {
    
    var onWriteCommentButtonTapped: (() -> Void)?
    
    @IBAction func writeCommentButtonAction(_ sender: UIButton) {
            // 當按鈕被點擊時，執行 closure
            onWriteCommentButtonTapped?()
        }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
