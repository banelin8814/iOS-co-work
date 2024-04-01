//
//  ProductDetailViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/2.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDetailViewController: STBaseViewController {
    
    var comments: [CommentForm] = []
    var displayedComments = 3
    
    private struct Segue {
        static let picker = "SeguePicker"
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var galleryView: LKGalleryView! {
        didSet {
            galleryView.frame.size.height = CGFloat(Int(UIScreen.width / 375.0 * 500.0))
            galleryView.delegate = self
        }
    }
    
    @IBOutlet weak var productPickerView: UIView!
    
    @IBOutlet weak var addToCarBtn: UIButton!
    
    @IBOutlet weak var baseView: UIView!
    
    private lazy var blurView: UIView = {
        let blurView = UIView(frame: tableView.frame)
        blurView.backgroundColor = .black.withAlphaComponent(0.4)
        return blurView
    }()
    
    private let datas: [ProductContentCategory] = [
        .description, .color, .size, .stock, .texture, .washing, .placeOfProduction, .remarks
    ]
    
    var product: Product? {
        didSet {
            guard let product = product, let galleryView = galleryView else { return }
            galleryView.datas = product.images
        }
    }
    
    private var pickerViewController: ProductPickerController?
    
    override var isHideNavigationBar: Bool { return true }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        guard let product = product else { return }
        galleryView.datas = product.images
        
        loadRealComments()
        
        // 加載假的評論資料
        //            loadFakeComments()
    }
    
    //    private func loadFakeComments() {
    //        userComments = [
    //            UserComment(username: "Alice", comment: "非常👍", rating: 5),
    //            UserComment(username: "Bob", comment: "沒想到生日活動有整單 5 折！", rating: 5),
    //            UserComment(username: "Cindy", comment: "下次還會再買～", rating: 4),
    //            UserComment(username: "David", comment: "Good Good!", rating: 3),
    //            UserComment(username: "Eva", comment: "我特地買給家人穿", rating: 5),
    //            UserComment(username: "Frank", comment: "不錯哦", rating: 5),
    //            UserComment(username: "Gray", comment: "超生火🔥 不買太可惜", rating: 3),
    //            UserComment(username: "Hunter", comment: "已經回購第 3 件", rating: 5),
    //            UserComment(username: "Ivy", comment: "朋友送的很喜歡！", rating: 5)
    //        ]
    //
    //        tableView.reloadData()
    //    }
    
    private func setupTableView() {
        tableView.lk_registerCellWithNib(
            identifier: String(describing: ProductDescriptionTableViewCell.self),
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: ProductDetailCell.color,
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: ProductDetailCell.label,
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: String(describing: UserCommentTableViewCell.self),
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: String(describing: SeeMoreCommentsCell.self),
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: String(describing: ProductDetailAddCommentButtonCell.self),
            bundle: nil
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.picker,
           let pickerVC = segue.destination as? ProductPickerController {
            pickerVC.delegate = self
            pickerVC.product = product
            pickerViewController = pickerVC
        }
    }
    
    // MARK: - Action
    @IBAction func didTouchAddToCarBtn(_ sender: UIButton) {
        if productPickerView.superview == nil {
            showProductPickerView()
        } else {
            guard
                let color = pickerViewController?.selectedColor,
                let size = pickerViewController?.selectedSize,
                let amount = pickerViewController?.selectedAmount,
                let product = product
            else {
                return
            }
            StorageManager.shared.saveOrder(
                color: color, size: size, amount: amount, product: product,
                completion: { result in
                    switch result {
                    case .success:
                        LKProgressHUD.showSuccess()
                        dismissPicker(pickerViewController!)
                    case .failure:
                        LKProgressHUD.showFailure(text: "儲存失敗！")
                    }
                }
            )
        }
    }
    
    func showProductPickerView() {
        let maxY = tableView.frame.maxY
        productPickerView.frame = CGRect(
            x: 0, y: maxY, width: UIScreen.width, height: 0.0
        )
        baseView.insertSubview(productPickerView, belowSubview: addToCarBtn.superview!)
        baseView.insertSubview(blurView, belowSubview: productPickerView)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                guard let self = self else { return }
                let height = 451.0 / 586.0 * self.tableView.frame.height
                self.productPickerView.frame = CGRect(
                    x: 0, y: maxY - height, width: UIScreen.width, height: height
                )
                self.isEnableAddToCarBtn(false)
            }
        )
    }
    
    func isEnableAddToCarBtn(_ flag: Bool) {
        if flag {
            addToCarBtn.isEnabled = true
            addToCarBtn.backgroundColor = .B1
        } else {
            addToCarBtn.isEnabled = false
            addToCarBtn.backgroundColor = .B4
        }
    }
    
    func loadRealComments() {
        guard let productId = product?.id else { return }
        
        APIManager.shared.fetchComments(forProductId: String(productId)) { [weak self] (comments, error) in
            DispatchQueue.main.async {
                if let comments = comments {
                    self?.comments = comments
                    self?.tableView.reloadData()
                } else {
                    print("Error loading comments: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    
    func loadMoreComments() {
        // 計算剩餘未顯示的評論數量
        let remainingComments = comments.count - displayedComments
        // 如果還有未顯示的評論，增加 displayedComments 的值
        if remainingComments > 0 {
            displayedComments += min(3, remainingComments)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ProductDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let baseCount = datas.count + 1 // 基本的 cell 數量，包括產品詳情和 "撰寫評論" 按鈕
        let commentCount = min(comments.count, displayedComments) // 當前顯示的評論數量
        let hasMoreCommentsToShow = comments.count > displayedComments // 是否還有更多評論未顯示
        return baseCount + commentCount + (hasMoreCommentsToShow ? 1 : 0) // 如果還有未顯示的評論，加上 "看更多評論" 按鈕的 cell
    }
    
    
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        switch indexPath.row {
    //        case 0..<datas.count:
    //            // 處理產品詳情相關的 cell
    //            guard let productDetail = product else {
    //                return UITableViewCell() // 如果 product 為 nil，則回傳一個基本的 cell
    //            }
    //            return datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: productDetail)
    //
    //        case datas.count:
    //            // 「撰寫評論」按鈕的 cell
    //            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailAddCommentButtonCell", for: indexPath) as? ProductDetailAddCommentButtonCell else {
    //                return UITableViewCell() // 如果轉型失敗，則回傳一個基本的 cell
    //            }
    //            cell.onWriteCommentButtonTapped = { [weak self] in
    //                self?.showCommentViewController()
    //            }
    //            return cell
    //
    //        case (datas.count + 1)...(datas.count + min(userComments.count, displayedComments)):
    //            let commentIndex = indexPath.row - datas.count - 1
    //            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "UserCommentTableViewCell", for: indexPath) as? UserCommentTableViewCell else {
    //                return UITableViewCell()
    //            }
    //            let comment = userComments[commentIndex]
    //            commentCell.nameLabel.text = comment.username
    //            commentCell.commentLabel.text = comment.comment
    //            // 更新星星的顯示
    //            commentCell.updateStars(rating: comment.rating)
    //
    //            commentCell.selectionStyle = .none
    //            return commentCell
    //
    //        default:
    //            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCommentsCell", for: indexPath) as? SeeMoreCommentsCell ?? SeeMoreCommentsCell()
    //            cell.onSeeMoreTapped = { [weak self] in
    //                self?.loadMoreComments()
    //            }
    //            return cell
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0..<datas.count:
            // 處理產品詳情相關的 cell
            guard let productDetail = product else {
                return UITableViewCell() // 如果 product 為 nil，則回傳一個基本的 cell
            }
            return datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: productDetail)
            
        case datas.count:
            // 「撰寫評論」按鈕的 cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailAddCommentButtonCell", for: indexPath) as? ProductDetailAddCommentButtonCell else {
                return UITableViewCell() // 如果轉型失敗，則回傳一個基本的 cell
            }
            cell.onWriteCommentButtonTapped = { [weak self] in
                self?.showCommentViewController()
            }
            return cell
            
        default:
            // 展示評論的 cell
            let actualIndex = indexPath.row - datas.count - 1 // 調整 index 以匹配 comments 數組
            if actualIndex < comments.count {
                let comment = comments[actualIndex]
                guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "UserCommentTableViewCell", for: indexPath) as? UserCommentTableViewCell else {
                    return UITableViewCell()
                }
                // 使用新的configureCell方法來配置單元格
                commentCell.configureCell(with: comment)
                return commentCell
            } else {
                // 處理「看更多評論」的 cell 或其他情況
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCommentsCell", for: indexPath) as? SeeMoreCommentsCell ?? SeeMoreCommentsCell()
                cell.onSeeMoreTapped = { [weak self] in
                    self?.loadMoreComments()
                }
                return cell
            }
        }
    }
    
}

extension ProductDetailViewController: LKGalleryViewDelegate {
    
    func sizeForItem(_ galleryView: LKGalleryView) -> CGSize {
        return CGSize(width: Int(UIScreen.width), height: Int(UIScreen.width / 375.0 * 500.0))
    }
}

extension ProductDetailViewController: ProductPickerControllerDelegate {
    
    func dismissPicker(_ controller: ProductPickerController) {
        let origin = productPickerView.frame
        let nextFrame = CGRect(x: origin.minX, y: origin.maxY, width: origin.width, height: origin.height)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.productPickerView.frame = nextFrame
                self?.blurView.removeFromSuperview()
                self?.isEnableAddToCarBtn(true)
            },
            completion: { [weak self] _ in
                self?.productPickerView.removeFromSuperview()
            }
        )
    }
    
    func valueChange(_ controller: ProductPickerController) {
        guard
            controller.selectedColor != nil,
            controller.selectedSize != nil,
            controller.selectedAmount != nil
        else {
            isEnableAddToCarBtn(false)
            return
        }
        isEnableAddToCarBtn(true)
    }
}

extension ProductDetailViewController {
    func showCommentViewController() {
        if let addCommentVC = storyboard?.instantiateViewController(withIdentifier: "AddCommentViewController") as? AddCommentViewController {
            // 設置代理
            addCommentVC.delegate = self
            
            // 設置產品ID
            if let productId = self.product?.id {
                addCommentVC.productId = productId
            }
            
            // 展示AddCommentViewController
            present(addCommentVC, animated: true, completion: nil)
        } else {
            print("無法初始化 AddCommentViewController")
        }
    }
}

extension ProductDetailViewController: AddCommentViewControllerDelegate {
    func didFinishAddingComment(rating: Int, comment: String, username: String) {
        // 假設id為0
        let newComment = CommentForm(id: 0, name: username, rate: rating, comment: comment)
        comments.append(newComment)
        tableView.reloadData()
    }
}
