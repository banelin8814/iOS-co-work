//
//  LobbyViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/13.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class LobbyViewController: STBaseViewController {
    
    //colorpicker
    private let dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0 // 初始时设置为完全透明
        return view
    }()
    let colorPickerView = ColorPickerView(frame: .zero)

    let titleLabel3: UILabel = {
        let label = UILabel()
        label.text = "1.選擇性別和顏色，推薦適合您的服飾"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.tintColor = .white
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        return label
    }()
    let titleLabel4: UILabel = {
        let label = UILabel()
        label.text = "2.選擇出生日期，參加生日月活動"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.tintColor = .white
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false

        return label
    }()
    
    @IBOutlet weak var lobbyView: LobbyView! {
        didSet {
            lobbyView.delegate = self
        }
    }

    private var datas: [PromotedProducts] = [] {
        didSet {
            lobbyView.reloadData()
        }
    }

    private let marketProvider = MarketProvider(httpClient: HTTPClient())

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: .asset(.Image_Logo02))
        
        lobbyView.beginHeaderRefresh()
        
        //colorpicker
        view.addSubview(dimmedBackgroundView)
        view.addSubview(colorPickerView)
        view.addSubview(titleLabel3)
        view.addSubview(titleLabel4)
        
        popUpView()
        colorPickerView.dismissHandler = {[weak self] in
            self?.colorPickerView.isHidden = true
            self?.dimmedBackgroundView.isHidden = true
            self?.titleLabel3.isHidden = true
            self?.titleLabel4.isHidden = true
        }
    }

    // MARK: - Action
    private func fetchData() {
        marketProvider.fetchHots(completion: { [weak self] result in
            switch result {
            case .success(let products):
                self?.datas = products
            case .failure:
                LKProgressHUD.showFailure(text: "讀取資料失敗！")
            }
        })
    }
    
    func popUpView() {
        self.dimmedBackgroundView.isHidden = false
        self.titleLabel3.isHidden = false
        self.titleLabel4.isHidden = false
        self.colorPickerView.isHidden = false
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            colorPickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2)
        ])
        dimmedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimmedBackgroundView.alpha = 1
        NSLayoutConstraint.activate([
            titleLabel3.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -45),
            titleLabel3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            titleLabel4.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -22),
            titleLabel4.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
    }
    
    func presentActivityPageViewController() {
        let storyboard = UIStoryboard(name: "Lobby", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: ActivityPageViewController.self)
        ) as? ActivityPageViewController else { return }
        viewController.modalPresentationStyle = .fullScreen
        
        self.present(viewController, animated: true)
    }
}

extension LobbyViewController: LobbyViewDelegate {
    
    func triggerRefresh(_ lobbyView: LobbyView) {
        fetchData()
    }

    // MARK: - UITableViewDataSource and UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: LobbyTableViewCell.self),
            for: indexPath
        )
        guard let lobbyCell = cell as? LobbyTableViewCell else { return cell }
        let product = datas[indexPath.section].products[indexPath.row]
        if indexPath.row % 2 == 0 {
            lobbyCell.singlePage(
                img: product.mainImage,
                title: product.title,
                description: product.description
            )
        } else {
            lobbyCell.multiplePages(
                imgs: product.images,
                title: product.title,
                description: product.description
            )
        }
        return lobbyCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 67.0 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 258.0 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0.01 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: LobbyTableViewHeaderView.self)
        ) as? LobbyTableViewHeaderView {
            headerView.titleLabel.text = datas[section].title
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let detailVC = UIStoryboard.product.instantiateViewController(
                withIdentifier: String(describing: ProductDetailViewController.self)
            ) as? ProductDetailViewController
        else {
            return
        }
        detailVC.product = datas[indexPath.section].products[indexPath.row]
        show(detailVC, sender: nil)
    }
    
}
