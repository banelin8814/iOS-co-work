//
//  ProfileViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/14.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileColorView: UIView! {
        didSet {
            let color = UserDefaults.standard.string(forKey: "SelectedColor") ?? "FFFFFF"
            self.profileColorView.backgroundColor = UIColor.hexStringToUIColor(hex: color)
        }
    }
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    private let manager = ProfileManager()
    
    private let userProvider = UserProvider(httpClient: HTTPClient())
    
    private var user: User? {
        didSet {
            if let user = user {
                updateUser(user)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBackgroundColor),
            name: NSNotification.Name("SelectedColorChanged"),
            object: nil
        )
//        fetchData()
    }
    
    @objc func updateBackgroundColor() {
        let color = UserDefaults.standard.string(forKey: "SelectedColor") ?? "FFFFFF"
        self.profileColorView.backgroundColor = UIColor.hexStringToUIColor(hex: color)
    }

//    // MARK: - Action
//    private func fetchData() {
//        userProvider.getUserProfile(completion: { [weak self] result in
//            switch result {
//            case .success(let user):
//                self?.user = user
//            case .failure:
//                LKProgressHUD.showFailure(text: "讀取資料失敗！")
//            }
//        })
//    }
    
    private func updateUser(_ user: User) {
        imageProfile.loadImage(user.picture, placeHolder: .asset(.Icons_36px_Profile_Normal))
        
        labelName.text = "Lily"
        labelInfo.text = "Lily"
        labelInfo.isHidden = false
    }
}

extension ProfileViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager.groups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.groups[section].items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCollectionViewCell else { return cell }
        let item = manager.groups[indexPath.section].items[indexPath.row]
        profileCell.layoutCell(image: item.image, text: item.title)
        return profileCell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: String(describing: ProfileCollectionReusableView.self),
                for: indexPath
            )
            guard let profileView = header as? ProfileCollectionReusableView else { return header }
            let group = manager.groups[indexPath.section]
            profileView.layoutView(title: group.title, actionText: group.action?.title)
            return profileView
        }
        return UICollectionReusableView()
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.width / 5.0, height: 60.0)
        } else if indexPath.section == 1 {
            return CGSize(width: UIScreen.width / 4.0, height: 60.0)
        }
        return CGSize.zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24.0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.width, height: 48.0)
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = manager.groups[indexPath.section].items[indexPath.row]
        if indexPath.section == 1 && indexPath.row == 5 {
            presentColorPickerView()
        }
    }
    
    private func presentColorPickerView() {
        let colorPickerView = ColorPickerView(frame: .zero)
        colorPickerView.birthdatePicker.isHidden = true
        
        lazy var dimmedBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            view.alpha = 0 // 初始时设置为完全透明
            return view
        }()
        
        lazy var titleLabel3: UILabel = {
            let label = UILabel()
            label.text = "選擇性別和顏色，推薦適合您的服飾"
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
        
        view.addSubview(dimmedBackgroundView)
        view.addSubview(colorPickerView)
        view.addSubview(titleLabel3)
        
        colorPickerView.isHidden = false
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
            titleLabel3.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            titleLabel3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])
        
        colorPickerView.dismissHandler = { [weak self] in
            colorPickerView.isHidden = true
            dimmedBackgroundView.isHidden = true
            titleLabel3.isHidden = true
        }
    }
    
}
