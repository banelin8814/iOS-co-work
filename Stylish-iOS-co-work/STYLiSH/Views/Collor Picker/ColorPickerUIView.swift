
import UIKit

class ColorPickerUIView: UIView {
    let titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "Pick Your"
        //        label.font = UIFont.regular(size: 22)
        label.font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        
        label.tintColor = .B2
        label.textColor = .B2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "Favorite Color!!"
        //        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.font = UIFont.systemFont(ofSize: 27, weight: .black)
        label.tintColor = .B1
        label.textColor = .B1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
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
        //        chooseButton.frame.width/2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didChooseColor), for: .touchUpInside)
        return button
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
            
            birthdatePicker.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            birthdatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: birthdatePicker.bottomAnchor, constant: 10),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            colorPicker.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: centerYAnchor,constant: 0),
            colorPicker.widthAnchor.constraint(equalToConstant: 200),
            colorPicker.heightAnchor.constraint(equalToConstant: 200),
            
            chooseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            chooseButton.centerYAnchor.constraint(equalTo: colorPicker.centerYAnchor),
            chooseButton.widthAnchor.constraint(equalToConstant: 90),
            chooseButton.heightAnchor.constraint(equalToConstant: 90),
        ])
        chooseButton.layer.cornerRadius = 45
        
        colorPicker.onChangeColor = {[weak self] color in
            self?.titleLabel2.tintColor = color
            self?.titleLabel2.textColor = color
        }
        
    }
    
    @objc func didChooseColor(){
        setupEmojiShower()
    }
    func setupEmojiShower() {
        let emojiEmitter = CAEmitterLayer()
        // 設定表情符號發射器的位置,在視圖的中心點
        emojiEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emojiEmitter.emitterShape = .circle
        emojiEmitter.emitterSize = CGSize(width: 1, height: 1)
        
        let emojis = ["😀", "😍", "🥳", "😎", "🚀", "🥳", "🎉", "🤩"] // 要使用的表情符號清單
        var emojiCells = [CAEmitterCell]()
        
        // 為每個表情符號建立發射粒子
        for emoji in emojis {
            let cell = makeEmojiEmitterCell(emoji: emoji)
            emojiCells.append(cell)
        }
        
        // 設定表情符號發射器的發射粒子
        emojiEmitter.emitterCells = emojiCells
        
        // 將表情符號發射器加入畫面的圖層中
        layer.addSublayer(emojiEmitter)
        
        // 在2秒後停止動畫
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            emojiEmitter.birthRate = 0
        }
    }
    
    func imageFrom(emoji: String) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 30)
        label.sizeToFit()
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    func makeEmojiEmitterCell(emoji: String) -> CAEmitterCell {
        let cell = CAEmitterCell()
        // 設定表情符號出現的頻率和持續時間
        cell.birthRate = 5
        cell.lifetime = 2
        cell.lifetimeRange = 0
        
        // 設定表情符號的初始速度和速度範圍
        cell.velocity = 200 // 向外的速度
        cell.velocityRange = 200
        
        // 設定表情符號發射的角度範圍
        cell.emissionRange = CGFloat.pi * 2 // 360度範圍
        
        // 設定表情符號的旋轉和縮放屬性
        cell.spin = 2
        cell.spinRange = 3
        cell.scale = 0.4 // 可以調整表情符號的縮放比例
        
        // 從文字建立表情符號的圖像
        if let emojiImage = imageFrom(emoji: emoji) {
            cell.contents = emojiImage.cgImage
        }
        
        return cell
    }
}
