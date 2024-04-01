//
//  CircularColorPickerView.swift
//  STYLiSH
//
//  Created by NY on 2024/3/31.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

// 匯入UIKit框架
import UIKit

// 定義CircularColorPickerView類別,繼承自UIView
class CircularColorPickerView: UIView {
    // 宣告一個選取的顏色屬性,類型為UIColor?
    var selectedColor: UIColor?
    // 宣告一個眼鏡儀視圖的屬性,類型為UIView?
    var eyedropperView: UIView?

    // 宣告一個私有旋轉角度屬性,類型為CGFloat,初始值為0
    private var rotationAngle: CGFloat = 0
    // 宣告一個私有觸控初始點屬性,類型為CGPoint?
    private var initialTouchPoint: CGPoint?

    var onChangeColor: ((UIColor) -> Void)?
    
    // 覆寫draw(_:)方法,用於繪製圓形顏色選擇器
    override func draw(_ rect: CGRect) {
        // 計算圓心點
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // 計算外半徑和內半徑
        let outerRadius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = outerRadius - 40
        // 定義顏色陣列
        let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]

        // 繪製背景
        let backgroundRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let backgroundPath = UIBezierPath(rect: backgroundRect)
        UIColor.white.setFill()
        backgroundPath.fill()

        // 計算每個顏色所占的角度步長
        let angleStep = 2 * .pi / CGFloat(colors.count)

        // 繪製每個顏色區域
        // 针对颜色数组中的每一个元素及其索引值进行枚举
        for (index, _) in colors.enumerated() {

           // 计算该颜色块的起始角度
           let startAngle = CGFloat(index) * angleStep - .pi / 2

           // 计算该颜色块的结束角度
           let endAngle = CGFloat(index + 1) * angleStep - .pi / 2

           // 创建一个新的贝塞尔路径对象
           let path = UIBezierPath()

           // 在路径上添加一个从startAngle到endAngle的圆弧，半径为outerRadius，顺时针方向
           path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

           // 在路径上添加一个从endAngle到startAngle的圆弧，半径为innerRadius，逆时针方向
           path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)

           // 闭合路径
           path.close()

           // 获取该颜色块的起始颜色
           let startColor = colors[index]

           // 获取该颜色块的结束颜色，如果索引超出数组范围，则从头开始
           let endColor = colors[(index + 1) % colors.count]

           // 创建一个颜色渐变对象，起始颜色为startColor，结束颜色为endColor
           let gradient = CGGradient(colorsSpace: nil, colors: [startColor.cgColor, endColor.cgColor] as CFArray, locations: [0.0, 1.0])
         
            
           // 获取当前图形上下文
           let context = UIGraphicsGetCurrentContext()

           // 保存当前图形上下文的状态
           context?.saveGState()

           // 将路径添加为裁剪路径
           path.addClip()

           // 计算渐变的起始点，位于内圆的startAngle处
           let startPoint = CGPoint(x: center.x + innerRadius * cos(startAngle), y: center.y + innerRadius * sin(startAngle))

           // 计算渐变的结束点，位于外圆的endAngle处
           let endPoint = CGPoint(x: center.x + outerRadius * cos(endAngle), y: center.y + outerRadius * sin(endAngle))

           // 在当前图形上下文中绘制线性渐变
           context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])

           // 恢复之前保存的图形上下文状态
           context?.restoreGState()

        }
    }

    // 覆寫touchesBegan(_:with:)方法,用於處理觸控開始事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 獲取第一個觸控點
        if let touch = touches.first {
            let location = touch.location(in: self)
            initialTouchPoint = location

            // 如果觸控點在顏色區域內
            if isPointInColorRegion(location) {
                // 更新眼鏡儀視圖的位置
                updateEyedropperPosition(location)
                // 獲取觸控點的顏色並賦值給selectedColor
                selectedColor = getColorAtPoint(location)
                // 打印選取的RGB顏色值
                if let color = selectedColor {
                    //傳給ColorPickerUIView
                    onChangeColor?(color)
                    print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
                }
            }
        }
    }

    // 覆寫touchesMoved(_:with:)方法,用於處理觸控移動事件
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 獲取第一個觸控點
        if let touch = touches.first {
            let location = touch.location(in: self)

            // 如果觸控點在顏色區域內
            if isPointInColorRegion(location) {
                // 更新眼鏡儀視圖的位置
                updateEyedropperPosition(location)
                // 獲取觸控點的顏色並賦值給selectedColor
                selectedColor = getColorAtPoint(location)
                // 打印選取的RGB顏色值
                if let color = selectedColor {
                    print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
                }
            }
            // 如果觸控點在顏色區域外
            else if var initialTouchPoint = initialTouchPoint {
                // 計算當前觸控點和初始觸控點的角度差
                let currentTouchPoint = location
                let angleDifference = angleFromPoints(initialTouchPoint, currentTouchPoint)
                // 更新旋轉角度
                rotationAngle += angleDifference
                // 更新初始觸控點
                initialTouchPoint = currentTouchPoint
                // 重新繪製視圖
                setNeedsDisplay()
            }
        }
    }

    // 更新眼鏡儀視圖的位置
    func updateEyedropperPosition(_ location: CGPoint) {
        // 如果眼鏡儀視圖尚未創建
        if eyedropperView == nil {
            // 創建眼鏡儀視圖並添加到視圖層級
            eyedropperView = createEyedropperView()
            addSubview(eyedropperView!)
        }
        // 更新眼鏡儀視圖的中心點
        eyedropperView?.center = location
    }

    // 創建眼鏡儀視圖
    func createEyedropperView() -> UIView {
        let size: CGFloat = 20
        let eyedropper = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        eyedropper.layer.borderWidth = 2
        eyedropper.layer.borderColor = UIColor.white.cgColor
        eyedropper.layer.cornerRadius = size / 2
        eyedropper.backgroundColor = .clear
        return eyedropper
    }

    // 獲取指定點的顏色
    func getColorAtPoint(_ point: CGPoint) -> UIColor? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        var pixelData: [UInt8] = [0, 0, 0, 0]
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context?.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)

        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    // 判斷指定點是否在顏色區域內
    func isPointInColorRegion(_ point: CGPoint) -> Bool {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = outerRadius - 40

        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)

        return distance >= innerRadius && distance <= outerRadius
    }

    // 計算兩點之間的角度差
    func angleFromPoints(_ startPoint: CGPoint, _ endPoint: CGPoint) -> CGFloat {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let v1 = CGPoint(x: startPoint.x - center.x, y: startPoint.y - center.y)
        let v2 = CGPoint(x: endPoint.x - center.x, y: endPoint.y - center.y)
        let angle = atan2(v2.y, v2.x) - atan2(v1.y, v1.x)
        return angle
    }
}

// 為UIColor擴充rgbComponents計算屬性
extension UIColor {
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red, green, blue)
    }
}
