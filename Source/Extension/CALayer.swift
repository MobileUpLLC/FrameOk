//
//  CALayer.swift

//
//  Created by Maxim Aliev on 25/07/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension CALayer {
    
    class func fill(rect: CGRect, in ctx: CGContext, color: UIColor, rounded: Bool = true) {
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rounded ? rect.height / 2 : 0)
        
        ctx.addPath(path.cgPath)
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
    }
    
    class func gradientFill(
        
        rect       : CGRect,
        in ctx     : CGContext,
        startColor : UIColor,
        endColor   : UIColor,
        startPoint : CGPoint = CGPoint(x: 0.5, y: 0.0),
        endPoint   : CGPoint = CGPoint(x: 0.5, y: 1.0),
        rounded    : Bool = true)
    {
        let startPoint = CGPoint(x: rect.maxX * startPoint.x, y: rect.maxY * startPoint.y)
        let endPoint   = CGPoint(x: rect.maxX * endPoint.x, y: rect.maxY * endPoint.y)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: rounded ? rect.height / 2 : 0)

        ctx.saveGState()
        path.addClip()
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [startColor.cgColor, endColor.cgColor] as CFArray, locations: [0.0, 1.0])!
        ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
        ctx.restoreGState()
    }
    
    class func stroke(rect: CGRect, in ctx: CGContext, lineWidth: CGFloat, color: UIColor, rounded: Bool = true) {
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rounded ? rect.height / 2 : 0)
        
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addPath(path.cgPath)
        ctx.strokePath()
    }
}
