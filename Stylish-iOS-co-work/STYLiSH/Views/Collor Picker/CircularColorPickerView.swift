//
//  CircularColorPickerView.swift
//  STYLiSH
//
//  Created by 林佑淳 on 2024/3/29.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import UIKit

class CircularColorPickerView: UIView {
    var selectedColor: UIColor?
    var eyedropperView: UIView?
    
    
    private var rotationAngle: CGFloat = 0
    private var initialTouchPoint: CGPoint?
    
    
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = outerRadius - 40
        let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        
        
        let backgroundRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
           let backgroundPath = UIBezierPath(rect: backgroundRect)
           UIColor.white.setFill()
           backgroundPath.fill()
        
        for (index, _) in colors.enumerated() {
            let startAngle = CGFloat(index) * 2 * .pi / CGFloat(colors.count) - .pi / 2
            let endAngle = CGFloat(index + 1) * 2 * .pi / CGFloat(colors.count) - .pi / 2
            
            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()
            
            let startColor = colors[index]
            let endColor = colors[(index + 1) % colors.count]
            
            let gradient = CGGradient(colorsSpace: nil, colors: [startColor.cgColor, endColor.cgColor] as CFArray, locations: [0.0, 1.0])
            
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            path.addClip()
            
            let startPoint = CGPoint(x: center.x + innerRadius * cos(startAngle), y: center.y + innerRadius * sin(startAngle))
            let endPoint = CGPoint(x: center.x + outerRadius * cos(endAngle), y: center.y + outerRadius * sin(endAngle))
            
            context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
            context?.restoreGState()
            
        }
    
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let location = touch.location(in: self)
//            updateEyedropperPosition(location)
//            selectedColor = getColorAtPoint(location)
//            if let color = selectedColor {
//                print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
//            }
//        }
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           if let touch = touches.first {
               let location = touch.location(in: self)
               initialTouchPoint = location
               
               if isPointInColorRegion(location) {
                   updateEyedropperPosition(location)
                   selectedColor = getColorAtPoint(location)
                   if let color = selectedColor {
                       print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
                   }
               }
           }
       }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let location = touch.location(in: self)
//            updateEyedropperPosition(location)
//            selectedColor = getColorAtPoint(location)
//            if let color = selectedColor {
//                print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
//            }
//        }
//    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                let location = touch.location(in: self)
                
                if isPointInColorRegion(location) {
                    updateEyedropperPosition(location)
                    selectedColor = getColorAtPoint(location)
                    if let color = selectedColor {
                        print("Selected RGB color: (\(color.rgbComponents.red), \(color.rgbComponents.green), \(color.rgbComponents.blue))")
                    }
                } else if var initialTouchPoint = initialTouchPoint {
                    let currentTouchPoint = location
                    let angleDifference = angleFromPoints(initialTouchPoint, currentTouchPoint)
                    rotationAngle += angleDifference
                    initialTouchPoint = currentTouchPoint
                    setNeedsDisplay()
                }
            }
        }
    
    func updateEyedropperPosition(_ location: CGPoint) {
        if eyedropperView == nil {
            eyedropperView = createEyedropperView()
            addSubview(eyedropperView!)
        }
        eyedropperView?.center = location
    }
    
    func createEyedropperView() -> UIView {
        let size: CGFloat = 20
        let eyedropper = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        eyedropper.layer.borderWidth = 2
        eyedropper.layer.borderColor = UIColor.white.cgColor
        eyedropper.layer.cornerRadius = size / 2
        eyedropper.backgroundColor = .clear
        return eyedropper
    }
    
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
    func isPointInColorRegion(_ point: CGPoint) -> Bool {
           let center = CGPoint(x: bounds.midX, y: bounds.midY)
           let outerRadius = min(bounds.width, bounds.height) / 2 - 20
           let innerRadius = outerRadius - 40
           
           let dx = point.x - center.x
           let dy = point.y - center.y
           let distance = sqrt(dx * dx + dy * dy)
           
           return distance >= innerRadius && distance <= outerRadius
       }
       
       func angleFromPoints(_ startPoint: CGPoint, _ endPoint: CGPoint) -> CGFloat {
           let center = CGPoint(x: bounds.midX, y: bounds.midY)
           let v1 = CGPoint(x: startPoint.x - center.x, y: startPoint.y - center.y)
           let v2 = CGPoint(x: endPoint.x - center.x, y: endPoint.y - center.y)
           let angle = atan2(v2.y, v2.x) - atan2(v1.y, v1.x)
           return angle
       }
    
    
}

extension UIColor {
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red, green, blue)
    }
}
