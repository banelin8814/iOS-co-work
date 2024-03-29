//
//  ActivityPageViewController.swift
//  STYLiSH
//
//  Created by NY on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class ActivityPageViewController: UIViewController {
    
    var products: [Product] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
}

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
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell
            cell.descriptionLabel.text = "今天我們依照你喜歡的顏色，推薦以下質感穿搭，快來看看吧！"
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainProductCell", for: indexPath) as! MainProductCell
            let product = products[indexPath.row]
//            cell.mainImage.kf.setImage(with: URL(string: product.mainImage))
//            cell.titleLabel.text = product.title
//            cell.descriptionLabel.text = product.description
            cell.mainImage = UIImageView(image: UIImage(named: "Image_Placeholder"))
            cell.titleLabel.text = "Title"
            cell.descriptionLabel.text = "Description"
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingProductCell", for: indexPath) as! MatchingProductCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            return cell
            
        default:
            break
        }
        return UITableViewCell()
    }
    
}

extension ActivityPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let product = products[indexPath.row]
//        cell.imageView.kf.setImage(with: URL(string: product.mainImage))
//        cell.titleLabel.text = product.title
//        cell.descriptionLabel.text = product.description
        cell.imageView = UIImageView(image: UIImage(named: "Image_Placeholder"))
        cell.titleLabel.text = "Title"
        cell.descriptionLabel.text = "Description"
        return cell
    }
    
    
}
