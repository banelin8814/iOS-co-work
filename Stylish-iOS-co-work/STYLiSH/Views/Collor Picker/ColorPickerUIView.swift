
import UIKit

class ColorPickerUIView: UIView {
    // 性別選擇器
    let genderSegmentedControl: UISegmentedControl = {
        let segments = ["男", "女"]
        let control = UISegmentedControl(items: segments)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // 出生日期選擇器
    let birthdatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // 色彩選擇器
    let colorPicker: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        addSubview(genderSegmentedControl)
        addSubview(birthdatePicker)
        addSubview(colorPicker)
        
        
        // 添加佈局約束
        NSLayoutConstraint.activate([
            genderSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            birthdatePicker.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 10),
            birthdatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            colorPicker.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorPicker.widthAnchor.constraint(equalToConstant: 200),
            colorPicker.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
