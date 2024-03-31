//
//  ProductDetailViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/2.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDetailViewController: STBaseViewController {

    var userComments: [UserComment] = []
    var displayedComments = 3  // 一開始顯示 3 條評論

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
        
        // 加載假的評論資料
            loadFakeComments()
    }
    
    private func loadFakeComments() {
        userComments = [
            UserComment(username: "用戶1", comment: "非常好的產品！", rating: 5),
            UserComment(username: "用戶2", comment: "很滿意！", rating: 4),
            UserComment(username: "用戶3", comment: "下次還會再買！", rating: 5),
        ]

        tableView.reloadData()
    }

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
    
    func loadMoreComments() {
        // 增加 displayedComments 的值，然後刷新 tableView
        displayedComments = min(userComments.count, displayedComments + 3)
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource
extension ProductDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentCount = min(userComments.count, 3)
        return datas.count + 1 + commentCount + (userComments.count > 3 ? 1 : 0)
    }


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

        case (datas.count + 1)...(datas.count + min(userComments.count, displayedComments)):
            let commentIndex = indexPath.row - datas.count - 1
            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "UserCommentTableViewCell", for: indexPath) as? UserCommentTableViewCell else {
                return UITableViewCell()
            }
            let comment = userComments[commentIndex]
            // TODO: 缺Comment 和 rating
            commentCell.nameLabel.text = comment.username
           
            return commentCell


        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCommentsCell", for: indexPath) as? SeeMoreCommentsCell ?? SeeMoreCommentsCell()
            cell.onSeeMoreTapped = { [weak self] in
                self?.loadMoreComments() // 這裡調用一個方法來加載更多評論
            }
            return cell
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
            present(addCommentVC, animated: true, completion: nil)
        } else {
            print("無法初始化 AddCommentViewController")
        }
    }

}
