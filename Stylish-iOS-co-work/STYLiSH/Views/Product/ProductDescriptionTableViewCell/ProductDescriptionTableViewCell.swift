//
//  ProductDescriptionTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/3.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDescriptionTableViewCell: ProductBasicCell {
    
    
    //for fetchStar Top
    private struct Constants {
        static let starsCount: Int = 5
        static let starContainerHeight: CGFloat = 40
    }
    var numberOfStars: Float = 0.0
    //for fetchStar bottom

    
    
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
    private func createStars() { /// 創建星星評分視圖
       for index in 1...Constants.starsCount { // 迭代星星的總數
           let star = makeStarIcon() // 創建單個星星圖標
           star.tag = index // 設置星星圖標的標籤為其索引值
           starsContainer.addArrangedSubview(star) // 將星星圖標添加到星星容器中
       }
    }

    private func makeStarIcon() -> UIImageView { // 創建單個星星圖標
       let image1 = UIImage(named: "icon_unfilled_star") // 加載未填充的星星圖片
       let image2 = UIImage(named: "icon_filled_star") // 加載填充的星星圖片
       let imageView = UIImageView(image: image1, highlightedImage: image2) // 創建圖片視圖，設置默認圖片和高亮狀態下的圖片
       imageView.translatesAutoresizingMaskIntoConstraints = false // 禁用圖片視圖的自動佈局
       imageView.contentMode = .scaleAspectFit // 設置圖片視圖的內容模式為等比縮放
       imageView.isUserInteractionEnabled = false // 禁用圖片視圖的用戶交互
       return imageView // 返回創建的圖片視圖
    }

    private func updateStarIcons() {
        for (index, starView) in starsContainer.arrangedSubviews.enumerated() {
            guard let starImageView = starView as? UIImageView else {
                return
            }
            
            let fillLevel = numberOfStars - Float(index)
            
            if fillLevel >= 1 {
                starImageView.image = UIImage(named: "icon_filled_star")
            } else if fillLevel > 0 {
                let partialFillImage = getPartialFillStarImage(fillLevel: fillLevel)
                starImageView.image = partialFillImage
            } else {
                starImageView.image = UIImage(named: "icon_unfilled_star")
            }
        }
    }

    private func getPartialFillStarImage(fillLevel: Float) -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            let unfilledStar = UIImage(named: "icon_unfilled_star")
            unfilledStar?.draw(in: CGRect(origin: .zero, size: size))
            
            let filledStar = UIImage(named: "icon_filled_star")
            let filledRect = CGRect(x: 0, y: 0, width: size.width * CGFloat(fillLevel), height: size.height)
            let clipRect = CGRect(x: 0, y: 0, width: filledRect.width, height: size.height)
            context.clip(to: clipRect)
            filledStar?.draw(in: CGRect(origin: .zero, size: size))
            
            let partialFillImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return partialFillImage
        }
        
        return nil
    }
    func updateNumberOfStars(_ numberOfStars: Float) {
           self.numberOfStars = numberOfStars
           updateStarIcons()
       }
}
