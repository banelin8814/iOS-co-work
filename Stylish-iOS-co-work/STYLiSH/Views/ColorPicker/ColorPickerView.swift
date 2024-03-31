//
//  ColorPickerView.swift
//  STYLiSH
//
//  Created by NY on 2024/3/31.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class ColorPickerView: UIView {
    
    var colorSelectedHandler: ((String, String) -> Void)?
    
    let titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "Pick Your"
        label.font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        
        label.tintColor = .B2
        label.textColor = .B2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "Favorite Color!!"
        label.font = UIFont.systemFont(ofSize: 27, weight: .black)
        label.tintColor = .B1
        label.textColor = .B1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 性別選擇器
    let genderSegmentedControl: UISegmentedControl = {
        let segments = ["men", "women", "non-binary"]
        let control = UISegmentedControl(items: segments)
        control.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // 出生日期選擇器
    let birthdatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // 色彩選擇器
    let colorPicker: CircularColorPickerView = {
        let picker = CircularColorPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let chooseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose!", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .B1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didChooseColor), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    var dismissHandler: (() -> Void)?
    
    var userChoosedColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 添加頂部圓角遮罩層
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        layer.mask = maskLayer
    }
    
    private func setupView() {
        self.backgroundColor = .white
        addSubview(colorPicker)
        addSubview(titleLabel1)
        addSubview(titleLabel2)
        addSubview(genderSegmentedControl)
        addSubview(birthdatePicker)
        addSubview(chooseButton)
        
        // 添加佈局約束
        NSLayoutConstraint.activate([
            titleLabel1.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 6),
            titleLabel2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            birthdatePicker.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 10),
            birthdatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            colorPicker.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            colorPicker.widthAnchor.constraint(equalToConstant: 200),
            colorPicker.heightAnchor.constraint(equalToConstant: 200),
            
            chooseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            chooseButton.centerYAnchor.constraint(equalTo: colorPicker.centerYAnchor),
            chooseButton.widthAnchor.constraint(equalToConstant: 90),
            chooseButton.heightAnchor.constraint(equalToConstant: 90)
        ])
        chooseButton.layer.cornerRadius = 45
        
        colorPicker.onChangeColor = {[weak self] color in
            self?.titleLabel2.tintColor = color
            self?.titleLabel2.textColor = color
            self?.userChoosedColor = color
        }
        
    }
    
    @objc func didChooseColor(sender: UIButton) {
        guard let selectedColor = colorPicker.selectedColor else {
            return
        }
        let color = selectedColor.toHexString
        let selectedSegment = genderSegmentedControl.selectedSegmentIndex
        let gender = genderSegmentedControl.titleForSegment(at: selectedSegment) ?? "women"
        print("===selectedColor: \(color), gender: \(gender)")

        // Save to UserDefaults
        UserDefaults.standard.set(color, forKey: "SelectedColor")
        UserDefaults.standard.set(gender, forKey: "SelectedGender")

        dismissHandler?()
    }
    
    @objc func didChangeColor(sender: CircularColorPickerView) {
        checkRequiredFields()
    }

    @objc func didChangeDate(sender: UIDatePicker) {
        checkRequiredFields()
    }

    @objc func didChangeSegment(sender: UISegmentedControl) {
        checkRequiredFields()
    }

    func checkRequiredFields() {
        if colorPicker.selectedColor != nil 
            && genderSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment {
            chooseButton.isEnabled = true
        } else {
            chooseButton.isEnabled = false
        }
    }
    
}
