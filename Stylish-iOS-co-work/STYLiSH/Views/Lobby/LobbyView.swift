//
//  LobbyView.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/22.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

protocol LobbyViewDelegate: UITableViewDataSource, UITableViewDelegate {
    func triggerRefresh(_ lobbyView: LobbyView)
}

class LobbyView: UIView {
    
    let banners = [
        "https://pse.is/5ramnu",
        "https://api.appworks-school.tw/assets/201807242228/keyvisual.jpg",
        "https://api.appworks-school.tw/assets/201807242222/keyvisual.jpg",
        "https://api.appworks-school.tw/assets/201807202140/keyvisual.jpg"
    ]

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self.delegate
            tableView.delegate = self.delegate
        }
    }
    
    weak var delegate: LobbyViewDelegate? {
        didSet {
            guard let tableView = tableView else { return }
            tableView.dataSource = self.delegate
            tableView.delegate = self.delegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableView()
    }
    // MARK: - Action
    
    func beginHeaderRefresh() {
        tableView.beginHeaderRefreshing()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.endHeaderRefreshing()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Private Method
    private func setupTableView() {
        
        tableView.register(
            LobbyBanner.self,
            forHeaderFooterViewReuseIdentifier: String(describing: LobbyTableViewHeaderView.self)
        )
        let headerView = LobbyBanner(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        tableView.tableHeaderView = headerView
        let allImages = banners
        headerView.configure(with: allImages)
        headerView.delegate = self
        
        tableView.lk_registerCellWithNib(
            identifier: String(describing: LobbyTableViewCell.self),
            bundle: nil
        )
        
        tableView.register(
            LobbyTableViewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: String(describing: LobbyTableViewHeaderView.self)
        )
        
        tableView.addRefreshHeader(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.delegate?.triggerRefresh(self)
        })
    }

}

extension LobbyView: TableViewCellDelegate {
    func didSelectBanner(in cell: LobbyBanner) {
        if let lobbyVC = delegate as? LobbyViewController {
            lobbyVC.presentActivityPageViewController()
        }
    }
}
