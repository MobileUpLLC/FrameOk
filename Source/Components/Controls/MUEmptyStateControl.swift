//
//  MUEmptyStateControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUEmptyStateControl

open class MUEmptyStateControl: NSObject {
    
    public enum Style {

        case none
        case table
        case view
    }
    
    // MARK: - Public properties
    
    open weak var emptyView: UIView?
    
    open var style: Style = .table
    
    open var isHidden: Bool = true { didSet { updateVisibility() } }
    
    // MARK: - Private properties
    
    private weak var contentView: UIView?
    
    private weak var emptyTableView: UITableView?
    
    private let refreshControl = MURefreshControl()
    
    // MARK: - Public methods
    
    open func setup(with controller: MUListController) {
        
        style = controller.emptyStateStyle

        contentView = controller.tableView ?? controller.collectionView

        switch style {

        case .none:
            return

        case .table:
            configureEmptyState(with: controller.hasRefresh ? controller.refreshControl : nil)

        case .view:
            configureEmptyState()
        }

        updateVisibility()
    }
    
    open func stopAnimation() {
        
        refreshControl.stopAnimation()
    }
    
    open func updateLayout() {
        
        emptyTableView?.viewForFooter(with: emptyView)
    }
    
    // MARK: - Private methods

    private func configureEmptyState(with refreshControl: MURefreshControl?) {
        
        guard self.emptyTableView == nil, let contentView = contentView else { return }
        
        let emptyTableView = UITableView(frame: contentView.frame)
        
        emptyTableView.backgroundColor = .clear
        
        emptyTableView.viewForFooter(with: emptyView)
        
        contentView.superview?.insertSubview(emptyTableView, at: 0)
        
        emptyTableView.appendConstraints(to: contentView)

        self.emptyTableView = emptyTableView
        
        guard let refreshControl = refreshControl else { return }
        
        refreshControl.setup(

            with      : emptyTableView,
            delegate  : refreshControl.delegate,
            tintColor : refreshControl.tintColor
        )
    }

    private func configureEmptyState() {

        guard let emptyView = emptyView else {

            assertionFailure("Missing empty view for \(self)")

            return
        }

        guard let conterParentView = contentView?.superview else {

            assertionFailure("Missing parent view for content view in \(self)")

            return
        }

        conterParentView.layoutSubview(emptyView, safe: true)
    }
    
    private func updateVisibility() {

        contentView?.isHidden = isHidden == false

        switch style {

        case .none:
            break

        case .table:
            updateTableVisibility()

        case .view:
            updateViewVisibility()
        }
    }

    private func updateTableVisibility() {

        emptyTableView?.isHidden = isHidden
        emptyTableView?.setFooterVisibility(asHidden: isHidden)
    }

    private func updateViewVisibility() {

        emptyView?.isHidden = isHidden
    }
}
