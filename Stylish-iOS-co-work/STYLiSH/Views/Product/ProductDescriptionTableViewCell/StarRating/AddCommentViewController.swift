//
//  AddCommentViewController.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/3/30.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

protocol AddCommentViewControllerDelegate: AnyObject {
    func didFinishAddingComment(rating: Int, comment: String, username: String)
}

class AddCommentViewController: UIViewController {
    weak var delegate: AddCommentViewControllerDelegate?

    // MARK: - Properties
    
    var productId: Int?
    
    /// 儲存選擇的星級
    private var selectedRate: Int = 0
    
    /// 新增點擊星級後的 Selection Feedback effect
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - User Interface
    
    private let container: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 70
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "商品評論"
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .hexStringToUIColor(hex: "#3F3A3A")
        return label
    }()
    
    private let attentionLabel: UILabel = {
        let label = UILabel()
        label.text = "注意事項 \n \n您的評論有可能用於您所評論的商品之廣告用途 \n如果其中有不適宜在網絡上發布的內容，此評論將可能不予顯示，請見諒"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = .zero
        label.textAlignment = .left
        label.textColor = .hexStringToUIColor(hex: "#3F3A3A")
        return label
    }()
    
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 20, weight: .semibold)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 2.0
        textView.textAlignment = .left
        textView.textColor = .hexStringToUIColor(hex: "#3F3A3A")
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .hexStringToUIColor(hex: "#3F3A3A")
        button.setTitle("送出", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(showAlertAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var starsContainer: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        /// 在星級上新增可以觸控的 UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectRate))
        stackView.addGestureRecognizer(tapGesture)
        
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStars()
        setupUI()
        
    }
    
    // MARK: - User Action
    
    @objc private func didSelectRate(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: starsContainer)
        let starWidth = starsContainer.bounds.width / CGFloat(Constants.starsCount)
        let rate = Int(location.x / starWidth) + 1
        
        /// 如果目前的星級不符合 selectedRate 就改變 rating
        if rate != self.selectedRate {
            feedbackGenerator.selectionChanged()
            self.selectedRate = rate
        }
        
        /// 更新星級的實心或空心狀態
        starsContainer.arrangedSubviews.forEach { subview in
            guard let starImageView = subview as? UIImageView else {
                return
            }
            starImageView.isHighlighted = starImageView.tag <= rate
        }
    }
    
    @objc private func showAlertAction() {
        // 確保 productId 不是 nil
        guard let productId = self.productId else {
            print("產品ID為nil，無法發送評論。")
            return
        }
        
        // 確保評論不是空白
        let commentText = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if commentText.isEmpty {
            print("評論不能為空。")
            return
        }
        
        // 使用 APIManager 發送評論
        APIManager.shared.postComment(userId: 14486, productId: productId, rate: selectedRate, comment: commentText) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.delegate?.didFinishAddingComment(rating: self?.selectedRate ?? 0, comment: commentText, username: "Lily")
                    self?.dismiss(animated: true, completion: nil)
                } else if let error = error {
                    // 處理錯誤
                    print("發送評論時發生錯誤: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Private methods
    
    private func createStars() {
        /// 收集用戶的評分
        for index in 1...Constants.starsCount {
            let star = makeStarIcon()
            star.tag = index
            starsContainer.addArrangedSubview(star)
        }
    }
    
    private func makeStarIcon() -> UIImageView {
        /// 設計星等的 UI
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_unfilled_star"), highlightedImage: #imageLiteral(resourceName: "icon_filled_star"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    private func setupUI() {
        
        view.backgroundColor = .hexStringToUIColor(hex: "#ffffff")
        
        /// container
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.containerHorizontalInsets).isActive = true
        container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.containerHorizontalInsets).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        /// star container
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        starsContainer.heightAnchor.constraint(equalToConstant: Constants.starContainerHeight).isActive = true
        
        /// commentTextView
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        /// ArrangedSubview
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(attentionLabel)
        container.addArrangedSubview(starsContainer)
        container.addArrangedSubview(commentTextView)
        container.addArrangedSubview(sendButton)
    }
    
    // MARK: - Constants {
    
    private struct Constants {
        static let starsCount: Int = 5
        
        static let sendButtonHeight: CGFloat = 50
        static let containerHorizontalInsets: CGFloat = 30
        static let starContainerHeight: CGFloat = 40
    }
    
}
