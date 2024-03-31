//
//  ActivityPageViewController.swift
//  STYLiSH
//
//  Created by NY on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class ActivityPageViewController: UIViewController {
    
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
        fetchMainData(color: "FFFFFF", gender: "women")
        fetchMatchData()
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
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
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
            
            guard let recommendedData = data else {
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
    
    //TODO: -
    func fetchMatchData() {
        APIManager.shared.sendRequest(
            urlString: "https://13.214.22.170/api/1.0",
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
