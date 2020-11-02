//
//  MURefreshControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MURefreshControlDelegate

public protocol MURefreshControlDelegate: class {
    
    func refreshControlDidRefresh()
}

// MARK: - MURefreshControl

open class MURefreshControl: NSObject {
    
    // MARK: - Public properties
    
    open weak var delegate: MURefreshControlDelegate?
    
    open var isRefreshing: Bool { return refreshControl?.isRefreshing ?? false }
    
    open var isScrolling: Bool { return scrollView?.isDragging ?? false }
    
    open var tintColor: UIColor? { return refreshControl?.tintColor }
    
    // MARK: - Private properties
    
    private weak var scrollView: UIScrollView?
    
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Public methods
    
    open func setup(with controller: MUListController, tintColor: UIColor? = nil) {
        
        guard controller.hasRefresh else { return }
        
        configure(with: controller.tableView ?? controller.collectionView, delegate: controller, tintColor: tintColor)
    }
    
    open func setup(with scrollView: UIScrollView?, delegate: MURefreshControlDelegate?, tintColor: UIColor? = nil) {
        
        configure(with: scrollView, delegate: delegate, tintColor: tintColor)
    }
    
    @objc open func startAnimation() {
        
        delegate?.refreshControlDidRefresh()
    }
    
    open func stopAnimation() {
        
        guard isRefreshing else { return }
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(resetScrollView(_:)), userInfo: nil, repeats: true)
    }
    
    // MARK: - Private methods
    
    @objc private func resetScrollView(_ timer: Timer) {
        
        if !isScrolling {
            
            refreshControl?.endRefreshing()
            
            resetTopContentInset()
            
            timer.invalidate()
        }
    }
    
    private func configure(with scrollView: UIScrollView?, delegate: MURefreshControlDelegate?, tintColor: UIColor? = nil) {
        
        self.delegate = delegate
        
        self.scrollView = scrollView
        
        configure(with: tintColor)
    }
    
    private func configure(with tintColor: UIColor? = nil) {
        
        refreshControl = UIRefreshControl()
        
        refreshControl!.tintColor = tintColor ?? refreshControl!.tintColor
        
        refreshControl!.addTarget(self, action: #selector(startAnimation), for: .valueChanged)
        
        scrollView?.addSubview(refreshControl!)
    }
    
    private func resetTopContentInset() {
        
        var contentInset = scrollView?.contentInset ?? .zero
        
        contentInset.top = 0
        
        scrollView?.contentInset = contentInset
    }
}
