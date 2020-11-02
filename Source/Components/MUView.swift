//
//  MUView.swift

//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
open class MUView: UIView {
    
    @IBInspectable open var clearBackgroundInRuntime: Bool = false
    
    @IBInspectable open var isRounded: Bool = false { didSet { updateRounded() } }
    
    @IBInspectable open var innerShadow: Bool = false { didSet { updateInnerShadow() } }
    
    @IBInspectable open var innerShadowBoundsInset: CGSize = .zero { didSet { updateInnerShadowBoundsInset() } }
    
    @IBInspectable open var innerShadowMaskToBounds: Bool = false { didSet { updateInnerShadowMaskToBounds() } }
    
    @IBInspectable open var innerShadowColor: UIColor = UIColor.black { didSet { updateInnerShadowColor() } }
    
    @IBInspectable open var innerShadowOffset: CGSize = CGSize(width: 0, height: 0) { didSet { updateInnerShadowOffset() } }
    
    @IBInspectable open var innerShadowOpacity: Float = 0 { didSet { updateInnerShadowOpacity() } }
    
    @IBInspectable open var innerShadowRadius: CGFloat = 0 { didSet { updateInnerShadowRadius() } }
    
    @IBInspectable open var maskedCornerRadius: CGFloat = 0 { didSet { updateLayerMask() } }
    
    @IBInspectable open var roundedTopLeftCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable open var roundedTopRightCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable open var roundedBottomLeftCorner: Bool = false { didSet { updateLayerMask() } }
    
    @IBInspectable open var roundedBottomRightCorner: Bool = false { didSet { updateLayerMask() } }
    
    open var innerShadowHidden: Bool = false { didSet { updateInnerShadowHiddenState() } }
    
    // MARK: - Private properties
    
    private weak var innerShadowLayer: CALayer?
    
    // MARK: - Override methods
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        updateRounded()
        
        #if !TARGET_INTERFACE_BUILDER
        
        updateBackground()
        
        #endif
    }
    
    // MARK: - Private methods
    
    private func updateBackground() {
        
        if clearBackgroundInRuntime {
            
            backgroundColor = .clear
        }
    }
    
    private func updateRounded() {
        
        if isRounded {
            
            cornerRadius = frame.height / 2
        }
    }
    
    private func updateInnerShadow() {
        
        if innerShadow {
            
            if innerShadowLayer == nil {
                
                innerShadowLayer = CALayer()
                
                if let innerShadowLayer = innerShadowLayer {
                    
                    innerShadowLayer.frame = self.bounds

                    let rect = innerShadowLayer.bounds.insetBy(
                        dx: innerShadowBoundsInset.width,
                        dy: innerShadowBoundsInset.height
                    )
                    
                    let path = UIBezierPath(rect: rect)
                    
                    let cutout = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
                    
                    path.append(cutout)
                    
                    innerShadowLayer.shadowPath = path.cgPath
                    innerShadowLayer.masksToBounds = innerShadowMaskToBounds
                    innerShadowLayer.shadowColor = innerShadowColor.cgColor
                    innerShadowLayer.shadowOffset = innerShadowOffset
                    innerShadowLayer.shadowOpacity = innerShadowOpacity
                    innerShadowLayer.shadowRadius = innerShadowRadius
                    innerShadowLayer.cornerRadius = self.cornerRadius
                    
                    self.layer.addSublayer(innerShadowLayer)
                }
            }
        } else {
            
            innerShadowLayer?.removeFromSuperlayer()
            
            innerShadowLayer = nil
        }
    }
    
    private func updateInnerShadowHiddenState() {
        
        innerShadowLayer?.isHidden = innerShadowHidden
    }
    
    private func updateInnerShadowBoundsInset() {
        
        if let innerShadowLayer = innerShadowLayer {

            let rect = innerShadowLayer.bounds.insetBy(
                dx: innerShadowBoundsInset.width,
                dy: innerShadowBoundsInset.height
            )
            
            let path = UIBezierPath(rect: rect)
            
            let cutout = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
            
            path.append(cutout)
            
            innerShadowLayer.shadowPath = path.cgPath
        }
    }
    
    private func updateInnerShadowMaskToBounds() {
        
        innerShadowLayer?.masksToBounds = innerShadowMaskToBounds
    }
    
    private func updateInnerShadowColor() {
        
        innerShadowLayer?.shadowColor = innerShadowColor.cgColor
    }
    
    private func updateInnerShadowOffset() {
        
        innerShadowLayer?.shadowOffset = innerShadowOffset
    }
    
    private func updateInnerShadowOpacity() {
        
        innerShadowLayer?.shadowOpacity = innerShadowOpacity
    }
    
    private func updateInnerShadowRadius() {
        
        innerShadowLayer?.shadowRadius = innerShadowRadius
    }
    
    private func updateLayerMask() {
        
        var corners: UIRectCorner = []
        
        if roundedTopLeftCorner { corners = corners.union(.topLeft) }
        if roundedTopRightCorner { corners = corners.union(.topRight) }
        if roundedBottomLeftCorner { corners = corners.union(.bottomLeft) }
        if roundedBottomRightCorner { corners = corners.union(.bottomRight) }
        
        masked(corners: corners, radius: maskedCornerRadius)
    }
}
