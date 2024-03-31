//
//  ProductDescriptionTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/3.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDescriptionTableViewCell: ProductBasicCell {
    
    private struct Constants {
        static let starsCount: Int = 5
        static let starContainerHeight: CGFloat = 40
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var idLbl: UILabel!
    
    @IBOutlet weak var detailLbl: UILabel!
    
    private var selectedRate: Int = 0
    
    private lazy var starsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal      
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutCell(product: Product) {
        titleLbl.text = product.title
        priceLbl.text = "NT$ \(product.price)"
        idLbl.text = String(product.id)
        detailLbl.text = product.story


//        updateStarIcons()
    }
    private func setupUI() {
            createStars()
            
            contentView.addSubview(starsContainer)
            starsContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                starsContainer.topAnchor.constraint(equalTo: priceLbl.bottomAnchor, constant: 3),
                starsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                starsContainer.widthAnchor.constraint(equalToConstant: 100),
                starsContainer.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
    private func createStars() {
        /// 收集用戶的評分
        for index in 1...Constants.starsCount {
            let star = makeStarIcon()
            star.tag = index
            starsContainer.addArrangedSubview(star)
        }
    }
    private func makeStarIcon() -> UIImageView {
        let image1 = UIImage(named: "icon_unfilled_star")
        let image2 = UIImage(named: "icon_filled_star")
        let imageView = UIImageView(image: image1, highlightedImage: image2)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }
//    private func updateStarIcons() {
//        for (index, starView) in starsContainer.arrangedSubviews.enumerated() {
//            guard let starImageView = starView as? UIImageView else {
//                return
//            }
//            starImageView.isHighlighted = index < selectedRate
//        }
//    }
}
