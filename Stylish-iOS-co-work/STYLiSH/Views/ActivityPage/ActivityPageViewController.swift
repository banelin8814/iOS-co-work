//
//  ActivityPageViewController.swift
//  STYLiSH
//
//  Created by NY on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit
import MarqueeLabel

class ActivityPageViewController: UIViewController {
    
    var stPaymentInfoCell: STPaymentInfoTableViewCell!
    
    var recommendProduct: Product?
    var matchingProducts: [Product] = []
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        close.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        setupCloseButton()

        let color = UserDefaults.standard.string(forKey: "SelectedColor") ?? "FFFFFF"
        let gender = UserDefaults.standard.string(forKey: "SelectedGender") ?? "women"
        fetchMainData(color: color, gender: gender)
        
        // Check if the current month matches the stored month in UserDefaults
        if let storedMonth = UserDefaults.standard.object(forKey: "SelectedBirthMonth") as? Int,
           let currentMonth = Calendar.current.dateComponents([.month], from: Date()).month,
           currentMonth == storedMonth {
            // Call the functions to setup scratch card and news ticker
            setupScratchCard()
            setupNewsTicker()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let storedMonth = UserDefaults.standard.object(forKey: "SelectedBirthMonth") as? Int,
           let currentMonth = Calendar.current.dateComponents([.month], from: Date()).month,
           currentMonth == storedMonth {
            setupNewsTicker()
        }
    }
    
    @objc private func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

}

//MARK: - Extension: fetching data

extension ActivityPageViewController {
    
    func fetchMainData(color: String, gender: String) {
        APIManager.shared.sendRequest(
            urlString: "https://traviss.beauty/api/1.0/recommendation?color=\(color)&gender=\(gender)",
            method: .post,
            parameters: ["key": "value"]
        ) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                return
            }
            
            guard data != nil else {
                print("Error: No data received")
                return
            }
            
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let recommendedData = try decoder.decode(RecommendProduct.self, from: data)
                    self.recommendProduct = recommendedData.data
                    print("成功：\(recommendedData)")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
    }
    
    //TODO: - stored id
    func fetchMatchData(id: String) {
        APIManager.shared.sendRequest(
            urlString: "https://traviss.beauty/api/1.0/recommendation_by_product?product_id=\(id)",
            method: .post,
            parameters: ["key": "value"]
        ) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                return
            }
            
            guard let recommendedData = data else {
                print("Error: No data received")
                return
            }
            
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let matchingData = try decoder.decode(RecommendProduct.self, from: data)
                    self.matchingProducts = [matchingData.data]
                    print("成功：\(matchingData)")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
    }
    
}

//MARK: - Extension: TableViewDataSource, TableViewDelegate

extension ActivityPageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecommendationCell.self),
                for: indexPath
            )
            guard let recommendationCell = cell as? RecommendationCell else { return cell }
            recommendationCell.descriptionLabel.text = "今天我們依照你喜歡的顏色，推薦以下質感穿搭，快來看看吧！"
            return recommendationCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MainProductCell.self),
                for: indexPath
            ) 
            guard let mainProductCell = cell as? MainProductCell else { return cell }
            guard let mainImage = recommendProduct?.mainImage, let url = URL(string: mainImage) else {
                return cell
            }
            mainProductCell.mainImage.kf.setImage(with: url)
            mainProductCell.mainImage.contentMode = .scaleAspectFill
            mainProductCell.titleLabel.text = recommendProduct?.title
            mainProductCell.descriptionLabel.text = recommendProduct?.description
            return mainProductCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MatchingProductCell.self),
                for: indexPath
            )
            guard let matchingProductCell = cell as? MatchingProductCell else { return cell }
            matchingProductCell.collectionView.delegate = self
            matchingProductCell.collectionView.dataSource = self
            if let layout = matchingProductCell.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 0
            }
    
            return matchingProductCell
            
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 67.0 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else if indexPath.section == 1 {
            return 300
        } else {
            return 250
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 16, y: 8, width: tableView.bounds.size.width - 32, height: 50)
        titleLabel.textColor = UIColor.darkGray
        
        switch section {
        case 0:
            titleLabel.text = "專屬推薦"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        case 1:
            titleLabel.text = "主打商品"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        case 2:
            titleLabel.text = "搭配商品"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        default:
            titleLabel.text = ""
        }
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        guard let productDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ProductDetailViewController"
        ) as? ProductDetailViewController else { return }
        productDetailVC.product = recommendProduct
        productDetailVC.backButtonAction = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        let navController = UINavigationController(rootViewController: productDetailVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: false, completion: nil)
    }
}

//MARK: - CollectionView

extension ActivityPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
//        return matchingProducts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CollectionViewCell.self),
            for: indexPath)
        guard let collectionViewCell = cell as? CollectionViewCell else { return cell }
//        let product = matchingProducts[indexPath.row]
//        collectionViewCell.imageView.kf.setImage(with: URL(string: product.mainImage))
//        collectionViewCell.imageView.contentMode = .scaleAspectFill
//        collectionViewCell.titleLabel.text = product.title
//        collectionViewCell.descriptionLabel.text = product.description
        collectionViewCell.imageView.image = UIImage(named: "Image_Placeholder")
        collectionViewCell.imageView.contentMode = .scaleAspectFill
        collectionViewCell.titleLabel.text = "Title"
        collectionViewCell.descriptionLabel.text = "Description"
        return collectionViewCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 120, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        guard let productDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ProductDetailViewController"
        ) as? ProductDetailViewController else { return }
        productDetailVC.product = matchingProducts[indexPath.item]
        productDetailVC.backButtonAction = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        let navController = UINavigationController(rootViewController: productDetailVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: false, completion: nil)
    }

}

//MARK: - Birth Month ActivityPage View
extension ActivityPageViewController: ScratchCardViewDelegate {
  
    func setupScratchCard() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 300))
        let scratchView = ScratchCardView(frame: CGRect(x: 20, y: 0, width: footerView.frame.width - 40, height: 280))
        let sectionHeader = UILabel(frame: CGRect(x: 20, y: 30, width: footerView.frame.width - 40, height: 30))
        sectionHeader.text = "刮刮樂"
        sectionHeader.textColor = UIColor.darkGray
        sectionHeader.font = UIFont.boldSystemFont(ofSize: 20)
        footerView.addSubview(scratchView)
        footerView.addSubview(sectionHeader)
        tableView.tableFooterView = footerView
    }
    
    func setupNewsTicker() {
        let lengthyLabel = MarqueeLabel(frame: CGRect(x: 0, y: 10, width: 0, height: 0), duration: 12.0, fadeLength: 0)
        lengthyLabel.frame = CGRect(x: 0, y: 85, width: view.bounds.width, height: 32)
        lengthyLabel.textColor = .white
        lengthyLabel.font = UIFont.systemFont(ofSize: 16)
        lengthyLabel.text = "🎉本日牡羊座運勢🎉 今天，星星閃爍著神秘的光芒，預示著你將迎來許多機遇和挑戰。勇敢地面對這些挑戰，並抓住機遇，因為它們將帶給你成長和成功的機會。🎁"
        lengthyLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "6b5c5b")
        lengthyLabel.holdScrolling = false
        lengthyLabel.animationDelay = 1
        view.addSubview(lengthyLabel)
    }
    
    //Coupon
    func scratchCardDidWin(_ view: ScratchCardView) {
        guard view.isWinningCard == true else { return }
        guard let cell = stPaymentInfoCell else {
            return
        }
        // Store coupon information in UserDefaults and track count
        let couponCount = UserDefaults.standard.integer(forKey: "CouponCount")
        UserDefaults.standard.set(couponCount + 1, forKey: "CouponCount")
        UserDefaults.standard.set("CouponInfo", forKey: "Coupon\(couponCount + 1)")
        
        let couponText = "五折優惠卷: \(couponCount + 1) 張"
        cell.couponTextField.text = couponText
        
        // Update total price label
        let productPrice = Int(cell.productPriceLabel.text ?? "") // Example product price
        let shipPrice = Int(cell.shipPriceLabel.text ?? "") // Example ship price
        let discountPrice = productPrice! / 2 // Apply 50% discount for coupon
        let totalPrice = discountPrice + shipPrice!
        cell.totalPriceLabel.text = "NT$ \(totalPrice)"
    }
    
}
