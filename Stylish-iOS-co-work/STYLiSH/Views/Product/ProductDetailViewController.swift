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
    
    var numberOfStars: Float?

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
        
    }
    
        fetchReview(id: product.id) { [weak self] result in
            switch result {
            case .success(let starReview):
                print("有拿到星星數：\(starReview)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    //for fetchStar Top
    enum APIError:Error {
        case urlError
        case responseError
        case generalError
        case noDataError
    }
    func fetchReview(id: Int, complition: @escaping (Result<RecommendProduct, Error>) -> Void) {
        guard let apiURL = URL(string: "https://chouyu.site/api/1.0/products/details?id=\(id)") else { return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: apiURL)) { data, httpResponse, error in
            if let error = error {
                print(error.localizedDescription)
                complition(.failure(APIError.generalError))
                return
            }
            guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                complition(.failure(APIError.responseError))
                return
            }
            print(httpResponse.statusCode)
            guard let data = data else {
                complition(.failure(APIError.noDataError))
                return
            }
            do {
                let docoder = JSONDecoder()
                let reponse = try docoder.decode(RecommendProduct.self, from: data)
                self.numberOfStars = reponse.data.rating
                complition(.success(reponse))
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProductDescriptionTableViewCell {
                        cell.updateNumberOfStars(self.numberOfStars ?? 0.0)
                    }
                }
            } catch {
                print(error.localizedDescription)
                complition(.failure(APIError.generalError))
            }
        }
        task.resume()
    }
    //for fetchStar bottom
    
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
        
        // 基本的 cell 數量，包括產品詳情和 "撰寫評論" 按鈕
        let baseCount = datas.count + 1
        // 目前顯示的評論數量
        let commentCount = min(comments.count, displayedComments)
        // 是否還有更多評論未顯示
        let hasMoreCommentsToShow = comments.count > displayedComments
        // 如果還有未顯示的評論，加上 "看更多評論" 按鈕的 cell
        return baseCount + commentCount + (hasMoreCommentsToShow ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//         guard let product = product else { return UITableViewCell() }
        switch indexPath.row {
        case 0..<datas.count:
            // 處理產品詳情相關的 cell
            guard let productDetail = product else {
                // 如果 product 為 nil，則回傳一個基本的 cell
                return UITableViewCell()
            }
            return datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: productDetail)
            
        case datas.count:
            // 「撰寫評論」按鈕的 cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailAddCommentButtonCell", for: indexPath) as? ProductDetailAddCommentButtonCell else {
                // 如果轉型失敗，則回傳一個基本的 cell
                return UITableViewCell()
            }
            cell.onWriteCommentButtonTapped = { [weak self] in
                self?.showCommentViewController()
            }
            return cell
            
        case datas.count + 1 ..< datas.count + 1 + displayedComments:
            // 展示評論的 cell
            let actualIndex = indexPath.row - (datas.count + 1)
            if actualIndex < comments.count {
                let comment = comments[actualIndex]
                guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "UserCommentTableViewCell", for: indexPath) as? UserCommentTableViewCell else {
                    return UITableViewCell() // 如果無法取得正確的 cell，返回空 cell
                }
                commentCell.configureCell(with: comment)
                commentCell.selectionStyle = .none
                return commentCell
            }
            
        default:
            // 「看更多評論」的 cell
            guard let seeMoreCommentsCell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCommentsCell", for: indexPath) as? SeeMoreCommentsCell else {
                return UITableViewCell() // 如果無法取得正確的 cell，返回空 cell
            }
            seeMoreCommentsCell.onSeeMoreTapped = { [weak self] in
                self?.loadMoreComments()
            }
            return seeMoreCommentsCell
        }
        
        // 預設返回一個空的 UITableViewCell
        return UITableViewCell()
       
        //for fetchStar top
//         let cell = datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: product)
//         return cell
        //for fetchStar bottom
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
            // 設定新增留言的 delegate
            addCommentVC.delegate = self
            
            // 設定產品ID
            if let productId = self.product?.id {
                addCommentVC.productId = productId
            }
            
            // show 出 AddCommentViewController
            present(addCommentVC, animated: true, completion: nil)
        } else {
            print("無法初始化 AddCommentViewController")
        }
    }
}

extension ProductDetailViewController: AddCommentViewControllerDelegate {
    func didFinishAddingComment(rating: Int, comment: String, username: String) {
        // 忽略 id
        let newComment = CommentForm(id: nil, name: username, rate: rating, comment: comment)
        
        comments.insert(newComment, at: 0)
        
        tableView.reloadData()
    }
}
