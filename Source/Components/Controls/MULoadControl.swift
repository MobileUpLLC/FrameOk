//
//  MULoadControl.swift
// 
//
//  Created by Dmitry Smirnov on 28.03.2020.
//  Copyright © 2020 MobileUp. All rights reserved.
//

import UIKit
import SkeletonView

// MARK: - MULoadControlDelegate

public protocol MULoadControlDelegate: class {

    func loadControlEmptyItems() -> [MUModel]
}

// MARK: - MULoadControl

open class MULoadControl: NSObject {
    
    // MARK: - Public properties

    public static var multilineCornerRadius: Int = 0 {

        didSet { SkeletonAppearance.default.multilineCornerRadius = multilineCornerRadius }
    }

    public static var multilineHeight: CGFloat = 15 {

        didSet { SkeletonAppearance.default.multilineHeight = multilineHeight }
    }

    public static var multilineLastLineFillPercent: Int = 70 {

        didSet { SkeletonAppearance.default.multilineLastLineFillPercent = multilineLastLineFillPercent }
    }

    public static var gradientBaseColor: UIColor? { didSet { updateGradientBaseColor() } }

    open weak var delegate: MULoadControlDelegate?
    
    open var isEnabled: Bool = true
    
    open var isLoading: Bool = false {
        
        didSet {
            
            guard isLoading != oldValue else { return }
            
            updateLoadingWithDelay()
        }
    }
    
    open var isManualSkeletonable = false
    
    open var shouldCreateOfEmptyItems: Bool = true
    
    // MARK: - Private properties
    
    private weak var controller: MUListController?
    
    private var isLoaded: Bool = false
    
    private static let fadeAnimationDuration = 0.3
    
    private static let delay = 0.01

    // MARK: - Public methods
    
    open func setup(with controller: MUViewController?) {

        self.controller = controller as? MUListController

        delegate = controller as? MULoadControlDelegate
    }
    
    // MARK: - Private methods

    private static func updateGradientBaseColor() {

        if let color = gradientBaseColor {

            SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: color)
        }
    }
    
    private func updateLoadingWithDelay() {
        
        updateEmptyEmptyItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (isLoading ? 0.01 : 0.3)) { [weak self] in
            
            self?.updateLoading()
        }
    }
    
    private func updateEmptyEmptyItems() {
        
        guard isEnabled, isLoading, let controller = controller else { return }
        
        if shouldCreateOfEmptyItems {
            
            controller.objects = createEmptyItems()
        }
        
        controller.tableView?.alpha = 0
    }
    
    private func updateLoading() {
        
        guard isEnabled else { return }
        
        if let tableView = controller?.tableView {
            
            return updateLoading(with: tableView)
        }
        
        if let collectionView = controller?.collectionView {
            
            return updateLoading(with: collectionView)
        }
    }
    
    private func updateLoading(with view: UIView) {
        
        guard isEnabled, isLoading else {
            
            return hideAnimatedGradientSkeleton(with: view)
        }
        
        prepareSubviewsForAnimation(with: view)
        
        showAnimatedGradientSkeleton(with: view)
    }
    
    private func prepareSubviewsForAnimation(with view: UIView) {
        
        view.isSkeletonable = true
        
        guard !isManualSkeletonable else { return }
        
        view.allSubviews().forEach {
            
            guard $0.isNoSkeletable == false else {
                
                return $0.isSkeletonable = false                
            }

            $0.isSkeletonable = true
        }
    }
    
    private func showAnimatedGradientSkeleton(with view: UIView) {
        
        view.showAnimatedGradientSkeleton(transition: .none)
        
        UIView.animate(withDuration: MULoadControl.fadeAnimationDuration, delay: MULoadControl.delay, animations: {
            
            view.alpha = 1
        })
    }
    
    private func hideAnimatedGradientSkeleton(with view: UIView) {
        
        isEnabled = false
        
        view.alpha = 1
        
        view.hideSkeleton(transition: .none)
        
        controller?.objects = controller?.objects ?? []
    }
    
    private func createEmptyItems() -> [MUModel] {
        
        return delegate?.loadControlEmptyItems() ?? []
    }
}

// MARK: - UIView

public extension UIView {
    
    static let isNoSkeletableKey = "isNoSkeletable"
    
    @IBInspectable var isNoSkeletable: Bool {
        
        set { setViewData(key: UIView.isNoSkeletableKey, value: newValue) }
        get { return (viewData(key: UIView.isNoSkeletableKey) as? Bool) ?? false }
    }
}

// MARK: - MUEmptyModel

public class MUEmptyModel: MUModel {

}
