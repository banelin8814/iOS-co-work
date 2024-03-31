//
//  ScratchCardView.swift
//  STYLiSH
//
//  Created by NY on 2024/4/1.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class ScratchCardView: UIView {
    var scratchView: ScratchView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = UILabel()
        contentView.backgroundColor = .systemYellow
        contentView.textAlignment = .center
        contentView.text = "再接再厲，可悲仔～～"
        contentView.font = .systemFont(ofSize: 25, weight: .black)
        contentView.textColor = .systemBrown
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

}

extension ScratchCardView: JXScratchViewDelegate {
    func scratchView(scratchView: ScratchView, didScratched percent: Float) {
        if percent >= 0.7 {
            scratchView.showContentView()
        }
    }
}
