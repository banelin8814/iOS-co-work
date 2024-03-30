//
//  TableViewCells.swift
//  STYLiSH
//
//  Created by NY on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class RecommendationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {}
}

class MainProductCell: UITableViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {}
}

class MatchingProductCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    override func setSelected(_ selected: Bool, animated: Bool) {}
}

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(image: UIImage?, title: String?, subtitle: String?) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = subtitle
    }
}
