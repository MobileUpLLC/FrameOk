//
//  UITableView.swift

//
//  Created by Maxim Aliev on 21/06/2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

@IBDesignable
public extension UITableView {
    
    // MARK: - Private properties
    
    static let headerTableViewHeightKey = "headerTableViewHeightKey"
    
    // MARK: - Public methods
    
    func scrollToFirstRow(animated: Bool = true) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        guard cellForRow(at: indexPath) != nil else { return }
        
        scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func scrollToTop() {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIView.animate(
            
            withDuration : 0.0,
            animations   : { self.scrollRectToVisible(rect, animated: false) },
            completion   : { _ in self.setContentOffset(.zero, animated: false) }
        )
    }
    
    // MARK: - Header View
    
    func showHeaderView() {
        
        tableHeaderView?.isHidden = false
        
        guard let height = viewData(key: UITableView.headerTableViewHeightKey) as? CGFloat else { return }
        
        setHeightForHeader(value: height)
    }
    
    func collapseHeaderView() {
        
        tableHeaderView?.isHidden = true
        
        guard let height = tableHeaderView?.frame.size.height, height > 0 else { return }
        
        setViewData(key: UITableView.headerTableViewHeightKey, value: tableHeaderView?.frame.size.height)
        
        setHeightForHeader(value: 0)
    }
    
    func setHeightForHeader(value: CGFloat) {
        
        let tableHeaderView = self.tableHeaderView
        
        tableHeaderView?.frame.size.height = value
        
        self.tableHeaderView = tableHeaderView
    }
    
    // MARK: - Empty View
    
    func viewForFooter(with view: UIView?) {
        
        guard let view = view else { return }
        
        let containerView = UIView(frame: frame)
        
        tableFooterView = containerView
        
        containerView.addSubview(view)
        
        view.appendConstraints(to: containerView)
    }
    
    func setFooterVisibility(asHidden isHidden: Bool) {
        
        guard let footerView = tableFooterView else { return }
        
        footerView.isHidden = isHidden
        
        contentInset.bottom = isHidden ? -footerView.frame.height : 0
    }
    
    // MARK: - Cell dequeuing
    
    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T? where T: UITableViewCell {
        
        return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T
    }
    
    func registerNib<T>(of: T.Type, reuseIdentifier: String? = nil) where T: UITableViewCell {
        
        let nibName = String(describing: T.self)
        
        register(UINib(nibName: nibName, bundle: .main), forCellReuseIdentifier: reuseIdentifier ?? nibName)
    }
}
