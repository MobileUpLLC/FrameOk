//
//  MUPopupControl.swift
//  MUSwiftFramework
//
//  Created by Ilya B Macmini on 22.05.2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//
// Pods: SwiftEntryKit

import UIKit
import SwiftEntryKit

// MARK: - MUPopupControl

open class MUPopupControl {

    // MARK: - AnimationType
    
    public enum AnimationType {
        
        case none
        case translation
        case fade
        case scale
    }
    
    //MARK: - ScreenInteraction

    public enum ScreenInteractionType {
        
        case dismiss
        case forward
        case absorbTouches
        
        //MARK: - Fileprivate properties
        
        fileprivate var coreInteractionType: EKAttributes.UserInteraction {
            
            switch self {
                
            case .absorbTouches : return EKAttributes.UserInteraction.absorbTouches
            case .dismiss       : return EKAttributes.UserInteraction.dismiss
            case .forward       : return EKAttributes.UserInteraction.forward
            }
        }
    }
    
    //MARK: - Priority

    public enum Priority {
        
        case max
        case high
        case normal
        case low
        case min
        case value(Int)
        
        //MARK: - Fileprivate properties
        
        fileprivate var corePriority: EKAttributes.Precedence.Priority {
            
            switch self {
                
            case .max              : return EKAttributes.Precedence.Priority.max
            case .high             : return EKAttributes.Precedence.Priority.high
            case .normal           : return EKAttributes.Precedence.Priority.normal
            case .low              : return EKAttributes.Precedence.Priority.low
            case .min              : return EKAttributes.Precedence.Priority.min
            case .value(let value) : return EKAttributes.Precedence.Priority.init(rawValue: value)
            }
        }
    }
    
    // MARK: - Position
    
    public enum Position {
        
        case top
        case center
        case bottom
    }
    
    public enum BackgroundColorStyle {
        
        case none
        case color(color: UIColor, alpha: CGFloat)
        case light
        case dark
        case extraDark
        
        //MARK: - Fileprivate properties
        
        fileprivate var coreBackgroundStyle: EKAttributes.BackgroundStyle {
            
            switch self {
                
            case .none                        : return backgroundColor(with: .clear, alpha: 0)
            case .dark                        : return backgroundColor(with: .darkGray, alpha: 0.4)
            case .extraDark                   : return backgroundColor(with: .black, alpha: 0.7)
            case .light                       : return backgroundColor(with: .lightGray, alpha: 0.1)
            case .color(let color, let alpha) : return backgroundColor(with: color, alpha: alpha)
            }
        }
        
        //MARK: - Private methods
        
        private func backgroundColor(with color: UIColor, alpha: CGFloat = 1) -> EKAttributes.BackgroundStyle {
            
            return EKAttributes.BackgroundStyle.color(color: EKColor(color.withAlphaComponent(alpha)))
        }

    }

    // MARK: - Public properties
    
    open weak var controller: MUViewController?
    
    // MARK: - Public methods
    
    open func setup(with controller: MUViewController) {
        
        self.controller = controller
    }
    
    open func showPopup(
        
        title       : String,
        message     : String?,
        buttonTitle : String,
        action      : (() -> Void)?
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(title: buttonTitle, handler : action)
        
        controller?.present(alert, animated: true, completion: nil)
    }

    open func showDialogAlert(
        
        title             : String,
        message           : String?,
        leftButtonTitle   : String,
        rightButtonTitle  : String,
        leftButtonStyle   : UIAlertAction.Style,
        rightButtonStyle  : UIAlertAction.Style,
        leftButtonAction  : (() -> Void)?,
        rightButtonAction : (() -> Void)?
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(title: leftButtonTitle, style: leftButtonStyle, handler: leftButtonAction)
        alert.addAction(title: rightButtonTitle, style: rightButtonStyle, handler: rightButtonAction)
        
        controller?.present(alert, animated: true, completion: nil)
    }
    
    open func showToast(
        
        title    : String,
        message  : String?,
        duration : TimeInterval
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        controller?.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            
            alert.dismiss(animated: true)
        }
    }
    
    @available(*, deprecated, message: "Use method show with screenInteractionType argument instead isClosedOnBackgroundTouch argument")
    open func show(
        
        customView                : MUCustomView,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool,
        isStatusBarHidden         : Bool
    ) {
        
       show(
        
        customView            : customView,
        position              : position,
        animationType         : animationType,
        backgroundColorStyle  : backgroundColorStyle,
        duration              : duration,
        screenInteractionType : isClosedOnBackgroundTouch ? .dismiss : .absorbTouches,
        isClosedOnSwipe       : isClosedOnSwipe,
        isShadowEnabled       : isShadowEnabled,
        isStatusBarHidden     : isStatusBarHidden
        )
    }
    
    open func show(
        
        customView            : MUCustomView,
        position              : Position,
        animationType         : AnimationType,
        backgroundColorStyle  : BackgroundColorStyle,
        duration              : TimeInterval,
        screenInteractionType : ScreenInteractionType,
        isClosedOnSwipe       : Bool,
        isShadowEnabled       : Bool,
        isStatusBarHidden     : Bool,
        popupName             : String? = nil,
        priority              : Priority = .normal
    ) {
        var attributes = getAttributes(position: position)
    
        attributes.name = popupName
        
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
    
        attributes.positionConstraints.size = .init(
    
            width  : .constant(value: customView.bounds.width),
            height : .constant(value: customView.bounds.height)
        )
    
        let animations = getAnimations(type: animationType)
        attributes.entranceAnimation = animations.entrance
        attributes.exitAnimation = animations.exit
        attributes.displayDuration = duration
        attributes.statusBar = isStatusBarHidden ? .hidden : .inferred
        attributes.screenInteraction = screenInteractionType.coreInteractionType
        attributes.entryInteraction = .forward
        attributes.precedence.priority = priority.corePriority
    
        attributes.scroll = isClosedOnSwipe ? .enabled(swipeable: true, pullbackAnimation: .jolt) : .disabled
    
        attributes.screenBackground = backgroundColorStyle.coreBackgroundStyle
        attributes.shadow = isShadowEnabled ? .active(with: .init(color: .black, opacity: 0.3, radius: 8)) : .none
    
        SwiftEntryKit.display(entry: customView, using: attributes)
    }

    open func showBottomPopup(

        controller           : MUViewController,
        backgroundColorStyle : BackgroundColorStyle,
        arrowIcon            : UIImage? = nil,
        arrowIconOffset      : CGFloat = 12
    ) {

        var attributes = getAttributes(position: .bottom)

        attributes.positionConstraints.size = .init(

            width  : .ratio(value: 1),
            height : .intrinsic
        )

        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden

        attributes.entryInteraction = .forward

        attributes.scroll = .edgeCrossingDisabled(swipeable: true)

        let animations = getAnimations(type: .translation)
        attributes.entranceAnimation = animations.entrance
        attributes.exitAnimation = animations.exit

        attributes.screenBackground = backgroundColorStyle.coreBackgroundStyle
        attributes.shadow = .none

        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss

        if let arrowIcon = arrowIcon {

            addPopupArrow(image: arrowIcon, to: controller.view, offset: arrowIconOffset)
        }

        SwiftEntryKit.display(entry: controller, using: attributes)
    }
    
    open func show(
        
        controller                : MUViewController,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool,
        widthRatio                : CGFloat,
        heightRatio               : CGFloat,
        arrowIcon                 : UIImage? = nil,
        arrowIconOffset           : CGFloat = 12,
        priority                  : Priority = .normal,
        onDisappear               : (() -> Void)? = nil
    ) {
        
        let size = EKAttributes.PositionConstraints.Size(
            
            width  : .ratio(value: widthRatio),
            height : .ratio(value: heightRatio)
        )
        
        show(
            
            controller                : controller,
            position                  : position,
            animationType             : animationType,
            backgroundColorStyle      : backgroundColorStyle,
            duration                  : duration,
            isClosedOnBackgroundTouch : isClosedOnBackgroundTouch,
            isClosedOnSwipe           : isClosedOnSwipe,
            isShadowEnabled           : isShadowEnabled,
            size                      : size,
            arrowIcon                 : arrowIcon,
            arrowIconOffset           : arrowIconOffset,
            priority                  : priority,
            onDisappear               : onDisappear
        )
    }
    
    open func show(
        
        controller                : MUViewController,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool,
        widthRatio                : CGFloat,
        topOffset                 : CGFloat,
        arrowIcon                 : UIImage? = nil,
        arrowIconOffset           : CGFloat = 12,
        priority                  : Priority = .normal,
        onDisappear               : (() -> Void)? = nil
    ) {
        
        let size = EKAttributes.PositionConstraints.Size(
            
            width  : .ratio(value: widthRatio),
            height : .offset(value: topOffset / 2)
        )
        
        show(
            
            controller                : controller,
            position                  : position,
            animationType             : animationType,
            backgroundColorStyle      : backgroundColorStyle,
            duration                  : duration,
            isClosedOnBackgroundTouch : isClosedOnBackgroundTouch,
            isClosedOnSwipe           : isClosedOnSwipe,
            isShadowEnabled           : isShadowEnabled,
            size                      : size,
            arrowIcon                 : arrowIcon,
            arrowIconOffset           : arrowIconOffset,
            priority                  : priority,
            onDisappear               : onDisappear
        )
    }
    
    open func show(
        
        controller                : MUViewController,
        position                  : Position,
        animationType             : AnimationType,
        backgroundColorStyle      : BackgroundColorStyle,
        duration                  : TimeInterval,
        isClosedOnBackgroundTouch : Bool,
        isClosedOnSwipe           : Bool,
        isShadowEnabled           : Bool,
        size                      : EKAttributes.PositionConstraints.Size,
        arrowIcon                 : UIImage? = nil,
        arrowIconOffset           : CGFloat = 12,
        priority                  : Priority = .normal,
        onDisappear               : (() -> Void)? = nil
    ) {
        
        var attributes = getAttributes(position: position)
        
        attributes.positionConstraints.size = size
        
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
    
        attributes.screenInteraction = isClosedOnBackgroundTouch ? .dismiss : .absorbTouches
        attributes.entryInteraction = .forward
        
        attributes.precedence.priority = priority.corePriority
        
        attributes.scroll = isClosedOnSwipe ? .edgeCrossingDisabled(swipeable: true) : .disabled
        
        let animations = getAnimations(type: animationType)
        attributes.entranceAnimation = animations.entrance
        attributes.exitAnimation = animations.exit
        
        attributes.screenBackground = backgroundColorStyle.coreBackgroundStyle
        attributes.shadow = isShadowEnabled ? .active(with: .init(color: .black, opacity: 0.3, radius: 6)) : .none
        
        attributes.displayDuration = duration
        
        if let arrowIcon = arrowIcon {
            
            addPopupArrow(image: arrowIcon, to: controller.view, offset: arrowIconOffset)
        }

        attributes.lifecycleEvents.didDisappear = onDisappear
        
        SwiftEntryKit.display(entry: controller, using: attributes)
    }
    
    open func dismiss(with completion: (() -> ())? = nil) {
        
        SwiftEntryKit.dismiss {
            
            completion?()
        }
    }
    
    public static func isCurrentDisplaying(popupName: String) -> Bool {
        
        return SwiftEntryKit.isCurrentlyDisplaying(entryNamed: popupName)
    }
    
    open func isCurrentDisplaying(popupName: String) -> Bool {
        
        return SwiftEntryKit.isCurrentlyDisplaying(entryNamed: popupName)
    }
    
    public static func closeAll() {
        
        SwiftEntryKit.dismiss()
    }
    
    // MARK: - Private methods
    
    private func getAttributes(position: Position) -> EKAttributes {
        
        switch position {
        
        case .top    : return EKAttributes.topFloat
        case .center : return EKAttributes.centerFloat
        case .bottom : return EKAttributes.bottomFloat
        }
    }
    
    private func getAnimations(type: AnimationType) -> (entrance: EKAttributes.Animation, exit: EKAttributes.Animation){
        
        switch type {
            
        case .none:
            
            return (EKAttributes.Animation.none, EKAttributes.Animation.none)
            
        case .translation:
            
            let entranceTranslate = EKAttributes.Animation(translate: .init(duration: 0.2))
            let exitTranslate = EKAttributes.Animation(translate: .init(duration: 0.2))
            return (entranceTranslate, exitTranslate)
            
        case .fade:
            
            let entranceFade = EKAttributes.Animation(fade: .init(from: 0, to: 1, duration: 0.3))
            let exitFade = EKAttributes.Animation(fade: .init(from: 1, to: 0, duration: 0.2))
            return (entranceFade, exitFade)
            
        case .scale:
            
            let entranceScale = EKAttributes.Animation(scale:EKAttributes.Animation.RangeAnimation(from: 0.1, to: 1, duration: 0.3))
            let exitScale = EKAttributes.Animation(scale: EKAttributes.Animation.RangeAnimation(from: 1, to: 0.1, duration: 0.2))
            return (entranceScale, exitScale)
        }
    }
    
    private func addPopupArrow(image: UIImage, to view: UIView, offset: CGFloat = 12) {
        
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: offset).isActive = true
    }
}

// MARK: - Popup

public extension MUViewController {

    func showPopup(

        title       : String,
        message     : String? = nil,
        buttonTitle : String = "OK",
        action      : (() -> Void)? = nil
    ) {

        popupControl.showPopup(

            title       : title,
            message     : message,
            buttonTitle : buttonTitle,
            action      : action
        )
    }

    func showDialogAlert(

        title             : String,
        message           : String? = nil,
        leftButtonTitle   : String = "Cancel",
        rightButtonTitle  : String = "OK",
        leftButtonStyle   : UIAlertAction.Style = .cancel,
        rightButtonStyle  : UIAlertAction.Style = .default,
        leftButtonAction  : (() -> Void)? = nil,
        rightButtonAction : @escaping (() -> Void)
    ) {

        popupControl.showDialogAlert(

            title             : title,
            message           : message,
            leftButtonTitle   : leftButtonTitle,
            rightButtonTitle  : rightButtonTitle,
            leftButtonStyle   : leftButtonStyle,
            rightButtonStyle  : rightButtonStyle,
            leftButtonAction  : leftButtonAction,
            rightButtonAction : rightButtonAction
        )
    }

    func showToast(

        title    : String,
        message  : String? = nil,
        duration : TimeInterval = 3
    ) {

        popupControl.showToast(

            title    : title,
            message  : message,
            duration : duration
        )
    }

    @available(*, deprecated, message: "Use method show with screenInteractionType argument instead isClosedOnBackgroundTouch argument")

    func show(

        customView                : MUCustomView,
        position                  : MUPopupControl.Position = .center,
        animationType             : MUPopupControl.AnimationType = .fade,
        backgroundColorStyle      : MUPopupControl.BackgroundColorStyle = .dark,
        duration                  : TimeInterval = .infinity,
        isClosedOnBackgroundTouch : Bool = true,
        isClosedOnSwipe           : Bool = true,
        isShadowEnabled           : Bool = true,
        isStatusBarHidden         : Bool = false
    ) {

        popupControl.show(

            customView            : customView,
            position              : position,
            animationType         : animationType,
            backgroundColorStyle  : backgroundColorStyle,
            duration              : duration,
            screenInteractionType : isClosedOnBackgroundTouch ? .dismiss : .absorbTouches,
            isClosedOnSwipe       : isClosedOnSwipe,
            isShadowEnabled       : isShadowEnabled,
            isStatusBarHidden     : isStatusBarHidden
        )
    }

    func show(

        customView                : MUCustomView,
        position                  : MUPopupControl.Position = .center,
        animationType             : MUPopupControl.AnimationType = .fade,
        backgroundColorStyle      : MUPopupControl.BackgroundColorStyle = .dark,
        duration                  : TimeInterval = .infinity,
        screenInteractionType     : MUPopupControl.ScreenInteractionType = .absorbTouches,
        isClosedOnSwipe           : Bool = true,
        isShadowEnabled           : Bool = true,
        isStatusBarHidden         : Bool = false,
        popupName                 : String? = nil,
        priority                  : MUPopupControl.Priority = .normal
        ) {

        popupControl.show(

            customView            : customView,
            position              : position,
            animationType         : animationType,
            backgroundColorStyle  : backgroundColorStyle,
            duration              : duration,
            screenInteractionType : screenInteractionType,
            isClosedOnSwipe       : isClosedOnSwipe,
            isShadowEnabled       : isShadowEnabled,
            isStatusBarHidden     : isStatusBarHidden,
            popupName             : popupName,
            priority              : priority
        )
    }

    func show(

        controller                : MUViewController,
        position                  : MUPopupControl.Position = .bottom,
        animationType             : MUPopupControl.AnimationType = .translation,
        backgroundColorStyle      : MUPopupControl.BackgroundColorStyle = .dark,
        duration                  : TimeInterval = .infinity,
        isClosedOnBackgroundTouch : Bool = true,
        isClosedOnSwipe           : Bool = false,
        isShadowEnabled           : Bool = true,
        widthRatio                : CGFloat = 1.0,
        heightRatio               : CGFloat = 0.6,
        arrowIcon                 : UIImage? = nil,
        priority                  : MUPopupControl.Priority = .normal
    ) {

        popupControl.show(

            controller                : controller,
            position                  : position,
            animationType             : animationType,
            backgroundColorStyle      : backgroundColorStyle,
            duration                  : duration,
            isClosedOnBackgroundTouch : isClosedOnBackgroundTouch,
            isClosedOnSwipe           : isClosedOnSwipe,
            isShadowEnabled           : isShadowEnabled,
            widthRatio                : widthRatio,
            heightRatio               : heightRatio,
            arrowIcon                 : arrowIcon,
            priority                  : priority
        )
    }

    func dismissPopup(with completion: (() -> ())? = nil) {

        popupControl.dismiss(with: completion)
    }
}

