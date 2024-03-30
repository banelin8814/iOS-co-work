//
//  ProductDetailViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/2.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDetailViewController: STBaseViewController {

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
            identifier: String(describing: ProductDetailButtonCell.self),
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
}

// MARK: - UITableViewDataSource
extension ProductDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard product != nil else { return 0 }
        return datas.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 確認 product 是否存在
        guard let product = product else { return UITableViewCell() }

        // 確認 indexPath 是否對應於原有的產品資訊
        if indexPath.row < datas.count {
            // 如果是，就使用原來的資料來配置 cell
            return datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: product)
        } else {
            // 如果不是，這意味著我們到了最後一個 cell，也就是我們要新增的「撰寫評論」按鈕
            guard let buttonCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ProductDetailButtonCell.self),
                for: indexPath
            ) as? ProductDetailButtonCell else {
                // 如果轉型失敗，輸出錯誤訊息並終止程式（開發階段使用，生產環境可能需要不同的處理方式）
                fatalError("無法取得 ProductDetailButtonCell")
            }

            // 設定 buttonCell 內的按鈕標題等內容
            // buttonCell.yourButton.setTitle("撰寫評論", for: .normal)
            
            // 為按鈕添加點擊事件的閉包
            buttonCell.onWriteCommentButtonTapped = { [weak self] in //Error: Value of type 'ProductDetailButtonCell' has no member 'onWriteCommentButtonTapped'
                // 當按鈕被點擊時，呼叫 showCommentViewController 方法來處理後續動作，如顯示評論界面
                self?.showCommentViewController() //Error: Value of type 'ProductDetailViewController' has no member 'showCommentViewController'
            }
            
            return buttonCell
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
            print("AddCommentViewController could not be instantiated from storyboard")
        }
    }

}
