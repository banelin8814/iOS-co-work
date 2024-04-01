//
//  LobbyBanner.swift
//  STYLiSH
//
//  Created by NY on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func didSelectBanner(in cell: LobbyBanner)
}

class LobbyBanner: UITableViewHeaderFooterView, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    var didSelectBanner: (() -> Void)?
    weak var delegate: TableViewCellDelegate?
   
    static let reuseIdentifier = "LobbyBanner"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupScrollView()
        setupPageControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        // Add constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        // Configure page control properties
        pageControl.frame = CGRect(x: 0, y: self.frame.height - 50, width: self.frame.width, height: 20)
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.isEnabled = true
        pageControl.pageIndicatorTintColor = .black
        addSubview(pageControl)
        // Add constraints for pageControl
        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    
    }
        
    func configure(with imageURLs: [String]) {
        // Add image views to scrollView
        for (index, imageURL) in imageURLs.enumerated() {
            let imageView = UIImageView()
            
            imageView.kf.setImage(with: URL(string: imageURL))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = CGRect(
                x: CGFloat(index) * UIScreen.width,
                y: 0,
                width: UIScreen.width,
                height: bounds.height
            )
            scrollView.addSubview(imageView)
            
            let labelStrings = [
                "選擇 \n 筆下所描繪的是色彩斑斕的人生畫卷 \n ---- 閃爍《色彩人生篇》",
                "於是 我也想要給你 一個那麼美好的自己 \n -----不朽《與自己和好如初》",
                "永遠 展現自信與專業 無法抵擋的男人魅力 \n -----復古《再一次經典》",
                "瞬間 在城市的角落 找到失落多時的記憶 \n -----印象《都會故事集》"
            ]

            let label = UILabel()
            label.text = labelStrings[index]
            label.font = UIFont.systemFont(ofSize: 12)
            label.numberOfLines = 0
            label.textColor = .white
            label.frame = CGRect(x: 10, y: 25, width: 250, height: 50)
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            label.layer.shadowRadius = 1.5
            label.layer.shadowOpacity = 1.2
            imageView.addSubview(label)
            
            if imageURL == "https://pse.is/5ramnu" {
                // Add a gesture recognizer to the image view
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bannerTapped))
                imageView.addGestureRecognizer(tapGestureRecognizer)
                imageView.isUserInteractionEnabled = true
            }
        }
        // Set content size of scrollView
        scrollView.contentSize = CGSize(width: CGFloat(imageURLs.count) * bounds.width, height: bounds.height)
        // Configure page control
        pageControl.numberOfPages = imageURLs.count
        // Add scroll view delegate to handle page control updates
        pageControl.addTarget(self, action: #selector(LobbyBanner.pageChanged), for: .valueChanged)
    }
    
    @objc func pageChanged() {
        let offset = CGPoint(x: (scrollView.frame.width) * CGFloat(pageControl.currentPage), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pageControl.currentPage = page
        let offset = CGPoint(x: CGFloat(page)*scrollView.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func bannerTapped() {
        delegate?.didSelectBanner(in: self)
    }
}
