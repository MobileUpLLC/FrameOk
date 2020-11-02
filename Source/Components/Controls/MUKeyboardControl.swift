//
//  MUKeyboardControl.swift

//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUKeyboardControl

open class MUKeyboardControl: NSObject {
    
    // MARK: - Public properties
    
    open weak var targetView: UIView?
    
    open weak var containerView: UIView?
    
    open weak var scrollView: UIScrollView?
    
    // MARK: - Private properties
    
    private var safeAreaBottomInset: CGFloat { return getBottomInset() }
    
    // MARK: - Public methods
    
    open func setup(with controller: MUViewController) {
        
        guard let targetView = controller.view else { return }
        
        self.targetView = targetView
        
        guard controller.hasScroll else { return }
        
        let containerView = UIView(frame: targetView.frame)
        let scrollView = UIScrollView(frame: targetView.frame)
        let contentView = UIView(frame: targetView.frame)
        
        self.scrollView = scrollView
        
        self.scrollView?.delegate = controller as? UIScrollViewDelegate
        
        containerView.backgroundColor = targetView.backgroundColor
        
        contentView.addSubview(targetView)
        scrollView.addSubview(contentView)
        containerView.addSubview(scrollView)
        
        contentView.clipsToBounds = false
        scrollView.clipsToBounds = false
        containerView.clipsToBounds = false
        
        controller.view = containerView
        
        scrollView.appendConstraints(to: containerView, withSafeArea: true)
        contentView.appendConstraints(to: scrollView)
        targetView.appendConstraints(to: contentView)
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let constraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        
        constraint.priority = .init(749)
        constraint.isActive = true
    }
    
    open func subscribeOnNotifications() {
        
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardWillShowNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardDidShowNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardWillHideNotification)
        NotificationCenter.addObserver(self, selector: #selector(notificationKeyboard), name: UIResponder.keyboardDidHideNotification)
    }
    
    open func unsubscribeOnNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    @objc private func notificationKeyboard(notification: Notification) {
        
        guard
            
            containerView != nil,
            
            let targetView = targetView,
            
            let userInfo = notification.userInfo,
            
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            
            else {
                
                return
        }
        
        let endFrame = targetView.convert(endFrameValue.cgRectValue, from: targetView.window)
        
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(curveValue.uint32Value << 16))
        
        let options: UIView.AnimationOptions = [.beginFromCurrentState, animationCurve]
        
        switch notification.name {
            
        case UIResponder.keyboardWillShowNotification : keyboardWillShow(with: endFrame, duration: duration, options: options)
        case UIResponder.keyboardDidShowNotification  : keyboardDidShow(with: endFrame)
        case UIResponder.keyboardWillHideNotification : keyboardWillHide(with: endFrame, duration: duration, options: options)
        case UIResponder.keyboardDidHideNotification  : keyboardDidHide(with : endFrame)
        default                                       : break
        }
    }
    
    @objc private func keyboardWillShow(with frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions) {
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            self.containerView?.setConstraint(type: .bottom, value: frame.height - self.safeAreaBottomInset)
        })
    }
    
    @objc private func keyboardDidShow(with frame: CGRect) {
        
        containerView?.setConstraint(type: .bottom, value: frame.height - self.safeAreaBottomInset )
    }
    
    @objc private func keyboardWillHide(with frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions) {
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            self.containerView?.setConstraint(type: .bottom, value: 0 )
        })
    }
    
    @objc private func keyboardDidHide(with frame: CGRect) {
        
        containerView?.setConstraint(type: .bottom, value: 0)
    }
    
    private func getBottomInset() -> CGFloat {
        
        var bottomInset: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            
            bottomInset = targetView?.safeAreaInsets.bottom ?? 0
        }
        
        return bottomInset
    }
}
