//
//  ScratchCardView.swift
//  STYLiSH
//
//  Created by NY on 2024/4/1.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

//Coupon
protocol ScratchCardViewDelegate: AnyObject {
    func scratchCardDidWin(_ view: ScratchCardView)
}

class ScratchCardView: UIView {
    
    weak var delegate: ScratchCardViewDelegate?
    
    var scratchView: ScratchView!
    var isWinningCard: Bool

    override init(frame: CGRect) {
        self.isWinningCard = false
        super.init(frame: frame)
        
        let textIndex = Int.random(in: 0..<2)
        let text: String
        if textIndex == 0 {
            text = "再接再厲! \n 可悲仔～～"
        } else {
            text = "恭喜中獎！ \n 全館商品5折"
            self.isWinningCard = true 
            checkIfWinningCard()
        }

        let contentView = UILabel()
        contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "6b5c5b")
        contentView.textAlignment = .center
        contentView.text = text
        contentView.font = .systemFont(ofSize: 25, weight: .black)
        contentView.textColor = .white
        contentView.numberOfLines = 0

        let maskView = UIView()
        maskView.backgroundColor = UIColor.lightGray

        let ratio = self.bounds.size.width/400
        scratchView = ScratchView(contentView: contentView, maskView: maskView)
        scratchView.delegate = self
        scratchView.strokeLineWidth = 25
        scratchView.strokeLineCap = .round

        scratchView.frame = CGRect(x: 33*ratio, y: 140*ratio, width: 337*ratio, height: 154*ratio)
        addSubview(scratchView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Coupon
    func checkIfWinningCard() {
//        isWinningCard = true
        
//        if isWinningCard {
            delegate?.scratchCardDidWin(self)
//        }
    }

}

extension ScratchCardView: JXScratchViewDelegate {
    func scratchView(scratchView: ScratchView, didScratched percent: Float) {
        if percent >= 0.7 {
            scratchView.showContentView()
        }
    }
}
