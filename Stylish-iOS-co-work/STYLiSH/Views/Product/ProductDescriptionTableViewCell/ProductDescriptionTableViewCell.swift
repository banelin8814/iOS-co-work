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
        //:1
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
        //:2
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
       return imageView // 返回創建的圖片視圖
    }

    private func updateStarIcons() {
        //4
        // 這個函數會更新星星圖標的顯示
        for (index, starView) in starsContainer.arrangedSubviews.enumerated() {
            // 對於 starsContainer 中的每個子視圖,用 index 記錄它的位置
            guard let starImageView = starView as? UIImageView else {
                // 檢查每個子視圖是否是 UIImageView,如果不是就跳過
                return
            }
            let fillLevel = numberOfStars - Float(index)
            // 計算這個星星應該填充的程度,填充的星星數 - 當前星星的位置
            
            if fillLevel >= 1 {
                // 如果應該填充一顆完整的星星
                starImageView.image = UIImage(named: "icon_filled_star")
                // 就顯示一張填滿的星星圖片
            } else if fillLevel > 0 {
                // 如果應該填充一部分星星
                let partialFillImage = getPartialFillStarImage(fillLevel: fillLevel)
                // 就計算部分填充的星星圖片
                starImageView.image = partialFillImage
                // 然後顯示這張部分填充的星星圖片
            } else {
                // 如果星星不需要填充
                starImageView.image = UIImage(named: "icon_unfilled_star")
                // 就顯示一張空心的星星圖片
            }
        }
    }

    private func getPartialFillStarImage(fillLevel: Float) -> UIImage? {
        //:5
        // 這個函數會根據填充程度生成一張部分填充的星星圖片
        let size = CGSize(width: 20, height: 20)
        // 設置星星圖片的尺寸為寬20,高20
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 開始在內存中畫圖,尺寸為 size,不透明,縮放比例為0
        if let context = UIGraphicsGetCurrentContext() {
            // 如果成功取得畫圖的上下文環境
            let unfilledStar = UIImage(named: "icon_unfilled_star")
            // 取得空心星星圖片
            unfilledStar?.draw(in: CGRect(origin: .zero, size: size))
            // 將空心星星圖片畫在畫布上,位置為左上角,尺寸為 size
            let filledStar = UIImage(named: "icon_filled_star")
            // 取得實心星星圖片
            let filledRect = CGRect(x: 0, y: 0, width: size.width * CGFloat(fillLevel), height: size.height)
            // 計算實心星星的填充區域,寬度 = 總寬度 x 填充程度,高度不變
            let clipRect = CGRect(x: 0, y: 0, width: filledRect.width, height: size.height)
            // 計算實心星星的裁剪區域,寬度和填充區域一致,高度不變
            context.clip(to: clipRect)
            // 將畫布的裁剪區域設為 clipRect
            filledStar?.draw(in: CGRect(origin: .zero, size: size))
            // 將實心星星畫在畫布上,位置為左上角,尺寸為 size,但只有在裁剪區域內的部分會被顯示
            let partialFillImage = UIGraphicsGetImageFromCurrentImageContext()
            // 從當前畫布內容生成一張圖片
            UIGraphicsEndImageContext()
            // 結束畫圖
            return partialFillImage
            // 返回部分填充的星星圖片
        }
        return nil
        // 如果畫圖失敗,就返回 nil
    }
    func updateNumberOfStars(_ numberOfStars: Float) {
        //:3
        // 這個函數用於更新星星的數量
        self.numberOfStars = numberOfStars
        // 將傳入的星星數量存儲在 self.numberOfStars 中
        updateStarIcons()
        // 調用 updateStarIcons 函數,根據新的星星數量更新星星的顯示
    }
}
