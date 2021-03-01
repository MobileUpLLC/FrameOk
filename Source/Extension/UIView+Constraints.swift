//
//  UIView+Constraints.swift
//  RBC
//
//  Created by Nikolai Timonin on 30.06.2020.
//  Copyright © 2020 MobileUp. All rights reserved.
//

import UIKit

// MARK: - LayoutInsets

public struct LayoutInsets {

    // MARK: - Public properites
    
    static var zero: LayoutInsets { self.init(top: 0, left: 0, bottom: 0, right: 0) }

    public var top: CGFloat?

    public var left: CGFloat?

    public var bottom: CGFloat?

    public var right: CGFloat?

    // MARK: - Public methods

    public static func insets(
        top    : CGFloat?  = 0,
        left   : CGFloat?  = 0,
        bottom : CGFloat?  = 0,
        right  : CGFloat?  = 0
    ) -> LayoutInsets {

        return LayoutInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

// MARK: - LayoutDimension

public struct LayoutDimension: OptionSet {

    // MARK: - Public properties
    
    public let rawValue: Int

    public static let height = LayoutDimension(rawValue: 1)

    public static let width = LayoutDimension(rawValue: 2)
    
    // MARK: - Public methods
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
}

// MARK: - AutoLayout Extensions

public extension UIView {

    // MARK: - Layout Subview

    func layoutCenter(_ view: UIView, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {

        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: xOffset).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yOffset).isActive = true
    }

    func layoutSubview(
        _ view      : UIView,
        with insets : LayoutInsets = .insets(top: 0, left: 0, bottom: 0, right: 0),
        safe        : Bool             = false
    ) {

        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        if let top = insets.top {

            if #available(iOS 11.0, *) {
                view.topAnchor.makeConstraint(equalTo: getTopAnchor(safe: safe), constant: top)
            } else {
                view.topAnchor.makeConstraint(equalTo: topAnchor, constant: top)
            }
        }

        if let left = insets.left {

            if #available(iOS 11.0, *) {
                view.leadingAnchor.makeConstraint(equalTo: getLeadingAnchor(safe: safe), constant: left)
            } else {
                view.leadingAnchor.makeConstraint(equalTo: leadingAnchor, constant: left)
            }
        }

        if let bottom = insets.bottom {

            if #available(iOS 11.0, *) {
                view.bottomAnchor.makeConstraint(equalTo: getBottomAnchor(safe: safe), constant: -bottom)
            } else {
                view.bottomAnchor.makeConstraint(equalTo: bottomAnchor, constant: -bottom)
            }
        }

        if let right = insets.right {

            if #available(iOS 11.0, *) {
                view.trailingAnchor.makeConstraint(equalTo: getTrailingAnchor(safe: safe), constant: -right)
            } else {
                view.trailingAnchor.makeConstraint(equalTo: trailingAnchor, constant: -right)
            }
        }
    }
    
    func layoutSize(height: CGFloat? = nil, width: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let height = height {
            
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let width = width {
            
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }

    func layoutEqualSize(to view: UIView, dimensitons: LayoutDimension = [.height, .width]) {

        translatesAutoresizingMaskIntoConstraints = false

        if dimensitons.contains(.height) {

            heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }

        if dimensitons.contains(.width) {

            widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }

    // MARK: - Find Constraint

    func findConstraint(byId id: String) -> NSLayoutConstraint? {

        for constraint in constraints {

            if constraint.identifier == id {

                return constraint
            }
        }

        return nil
    }

    func findConstraint(type: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {

        if let constraint = findConstraintInSuperview(type: type) {

            return constraint
        }

        for constraint in constraints {

            if constraint.firstAttribute == type && constraint.secondAttribute != type {

                return constraint
            }
        }

        return nil
    }

    func findConstraintInSuperview(type: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {

        if let superview = superview {

            for constraint in superview.constraints {

                let isFirstItemIsSelf = (constraint.firstItem as? UIView) == self

                let isSecondItemIsSelf = (constraint.secondItem as? UIView) == self

                let isConstraintAssociatedWithSelf = (isFirstItemIsSelf || isSecondItemIsSelf)

                if constraint.firstAttribute == type && isConstraintAssociatedWithSelf {

                    return constraint
                }
            }
        }

        return nil
    }

    // MARK: - Set Constraint

    func setConstraint(type: NSLayoutConstraint.Attribute, value: CGFloat, updateSuperview: Bool = true) {

        if let constraint = findConstraint(type: type) {

            constraint.constant = value

        } else {

            switch type {

            case .width  : widthAnchor.constraint(equalToConstant : value).isActive = true
            case .height : heightAnchor.constraint(equalToConstant : value).isActive = true
            default      : break
            }
        }

        if updateSuperview {

            superview?.layoutIfNeeded()
        } else {
            layoutIfNeeded()
        }
    }

    func appendConstraints(to view: UIView, withSafeArea isWithSafeArea: Bool = false) {

        translatesAutoresizingMaskIntoConstraints = false

        if isWithSafeArea, #available(iOS 11.0, *) {

            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        } else {

            topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }

    func append(toLeft view: UIView, rightOf rightView: UIView? = nil, margin: CGFloat = 0) {

        view.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        if let rightView = rightView {

            leadingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: margin).isActive = true
        } else {
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        }
    }
}

// MARK: - Anchors

@available(iOS 11.0, *)
public extension UIView {

    func getTopAnchor(safe: Bool) -> NSLayoutYAxisAnchor {

        return safe ? safeAreaLayoutGuide.topAnchor : topAnchor
    }

    func getBottomAnchor(safe: Bool) -> NSLayoutYAxisAnchor {

        return safe ? safeAreaLayoutGuide.bottomAnchor : bottomAnchor
    }

    func getLeadingAnchor(safe: Bool) -> NSLayoutXAxisAnchor {

        return safe ? safeAreaLayoutGuide.leadingAnchor : leadingAnchor
    }

    func getTrailingAnchor(safe: Bool) -> NSLayoutXAxisAnchor {

        return safe ? safeAreaLayoutGuide.trailingAnchor : trailingAnchor
    }
}

// MARK: - NSLayoutAnchor

public extension NSLayoutAnchor {

    @objc func makeConstraint(equalTo anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat) {

        constraint(equalTo: anchor, constant: constant).isActive = true
    }
}
