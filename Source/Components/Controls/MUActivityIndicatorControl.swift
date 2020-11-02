//
//  MUActivityIndicatorControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUActivityIndicatorControl

open class MUActivityIndicatorControl: NSObject {
    
    // MARK: - Style
    
    public enum Style {
        
        case lightLarge
        case light
        case dark
    }
    
    // MARK: - Public properties
    
    public static var defaultStyle: Style = .light
    
    open var isEnabled: Bool = true
    
    open var style: Style = MUActivityIndicatorControl.defaultStyle { didSet { updateStyle() } }
    
    open var defaultDelay: TimeInterval = 0.6
    
    open weak var view: UIView?
    
    open weak var indicatorContainer: UIView?
    
    // MARK: - Private methods
    
    private weak var indicator: UIActivityIndicatorView?
    
    // MARK: - Public methods
    
    open func showIndicator(above view: UIView, delay: TimeInterval? = nil) {
        
        guard isEnabled else { return }
        
        let delay = delay ?? defaultDelay
        
        guard self.indicatorContainer == nil else {
            
            return
        }
        
        let indicatorContainer = UIView()
        
        view.addSubview(indicatorContainer)
        
        indicatorContainer.appendConstraints(to: view)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        
        indicatorContainer.addSubview(indicator)
        
        indicator.startAnimating()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: indicatorContainer.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: indicatorContainer.centerYAnchor).isActive = true
        
        self.indicatorContainer = indicatorContainer
        
        self.indicator = indicator
        
        updateStyle()
        
        if delay > 0 {
            
            self.indicatorContainer?.alpha = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                
                self?.indicatorContainer?.alpha = 1
            })
        }
    }
    
    open func hideIndicator() {
        
        guard let indicatorContainer = indicatorContainer else {
            
            return
        }
        
        indicatorContainer.removeFromSuperview()
        
        self.indicatorContainer = nil
    }
    
    // MARK: - Private methods
    
    private func updateStyle() {
        
        switch style {
        case .lightLarge : indicator?.style = .whiteLarge
        case .light      : indicator?.style = .white
        case .dark       : indicator?.style = .gray
        }
        
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        
        switch style {
        case .lightLarge : indicatorContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        case .light      : indicatorContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        case .dark       : indicatorContainer?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
}
