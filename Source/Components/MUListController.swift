//
//  ObjectTableController.swift

//
//  Created by Dmitry Smirnov on 28.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUListControlDelegate

@objc public protocol MUListControlDelegate: class {
    
    func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String?
    
    func cellIdentifier(at indexPath: IndexPath) -> String?

    @available(*, deprecated, message: "Use cellDidSelected(for:at:) instead")
    func cellDidSelected(for object: MUModel)

    func cellDidSelected(for object: MUModel, at indexPath: IndexPath)
    
    func getSection(for object: MUModel) -> String?
    
    func isObjectChanged(for object: MUModel) -> Bool
    
    func objectDidChanged(with objects: [MUModel])
    
    func scrollDidScroll(_ scrollView: UIScrollView)
    
    // MARK: - UITableViewDataSource
    
    @objc optional func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    @objc optional func tableView2(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    // MARK: - UITableViewDelegate
    
    @objc optional func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    @objc optional func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    // MARK: - UICollectionViewDataSource
    
    @objc optional func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> CGFloat
    
    // MARK: - UICollectionViewDelegate
    
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

// MARK: - MUListController

open class MUListController: MUViewController, MUListControlDelegate, MUReusableControllerProvider, MULoadControlDelegate {
    
    // MARK: - Public properties
    
    open var hasRefresh: Bool { return false }
    
    open var hasPagination: Bool { return false }
    
    open var hasSections: Bool { return false }

    open var emptyStateStyle: MUEmptyStateControl.Style { .none }
    
    open var hasCache: Bool { return false }
    
    open var cacheKey: String? { return nil }
    
    @IBOutlet open weak var tableView: UITableView?
    
    @IBOutlet open weak var collectionView: UICollectionView?
    
    @IBOutlet open weak var emptyView: UIView? { didSet { emptyStateControl.emptyView = emptyView } }
    
    open var objects: [MUModel] {
        
        set { setObjects(with: newValue)  }
        get { return getObjects() }
    }
    
    open var unusedControllers: [String: Set<MUViewController>] = [:]

    open var usedControllers: [String: [IndexPath: MUViewController]] = [:]

    open var reusedControllerTypes: [String: MUViewController.Type] = [:]
    
    open var loadControlEmptyItemsCount = 20
    
    // MARK: - Controls
    
    open var tableControl = MUTableControl()
    
    open var collectionControl = MUCollectionControl()
    
    open var emptyStateControl = MUEmptyStateControl()
    
    open var refreshControl = MURefreshControl()
    
    open var paginationControl = MUPaginationControl()
    
    open var cacheControl: MUCacheControlProtocol? { return nil }
    
    // MARK: - Private properties
    
    private var activityTimer: Timer?

    private var lastCellIdentifier: String = ""
    
    // MARK: - Override methods
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cacheControl?.setup(with: self)
        
        tableControl.setup(with: self)
        tableControl.hasSections = hasSections
        
        collectionControl.setup(with: self)
        
        paginationControl.setup(with: self)
        
        refreshControl.setup(with: self)
        
        emptyStateControl.setup(with: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    open override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        emptyStateControl.updateLayout()
    }
    
    open override func appErrorDidBecome(error: Error) {
        
        super.appErrorDidBecome(error: error)
        
        paginationControl.cancelLastPage()
        
        hideActivityIndicators(withDelay: 0.3)
    }
    
    // MARK: - Public methods
    
    @objc open func hideActivityIndicators() {
        
        isLoading = false
        
        refreshControl.stopAnimation()
        
        emptyStateControl.stopAnimation()
        
        paginationControl.stopAnimationIfNeeded()
    }
    
    open func hideActivityIndicators(withDelay delay: TimeInterval) {
        
        activityTimer?.invalidate()
        
        activityTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(hideActivityIndicators as () -> ()), userInfo: nil, repeats: false)
    }
    
    // MARK: - Request
    
    open func beginRequest() {
        
        update(objects: [])
    }
    
    open func update(objects newObjects: [MUModel]) {
        
        if refreshControl.isRefreshing {
            
            updateWithTimeInterval(objects: newObjects)
        } else {
            updateWithoutTimeInterval(objects: newObjects)
        }
        
        hideActivityIndicators()
    }
    
    open func updateWithTimeInterval(objects newObjects: [MUModel], interval: Double = 0.1) {
        
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateIfNeeded(_:)), userInfo: ["newObjects": newObjects], repeats: true)
    }
    
    open func updateWithoutTimeInterval(objects newObjects: [MUModel]) {
        
        if paginationControl.page > 1 {
            
            objects += newObjects
        } else {
            objects = newObjects
        }
        
        paginationControl.hasMoreObjects = newObjects.count > 0
    }
    
    open func requestObjects(withIndicator: Bool = true) {
        
        if withIndicator {
            
            isLoading = true
        }
        
        beginRequest()
    }
    
    open func registerClass<T>(of: T.Type, reuseIdentifier: String? = nil) where T: UITableViewCell {

        lastCellIdentifier = reuseIdentifier ?? String(describing: T.self)
        
        tableView?.register(T.self, forCellReuseIdentifier: lastCellIdentifier)
    }
    
    open func registerNib<T>(of: T.Type, reuseIdentifier: String? = nil) where T: UITableViewCell {

        lastCellIdentifier = reuseIdentifier ?? String(describing: T.self)
        
        tableView?.registerNib(of: T.self, reuseIdentifier: lastCellIdentifier)
    }

    open func registerNib<T: UICollectionViewCell>(of: T.Type) {

        lastCellIdentifier = String(describing: T.self)

        collectionView?.register(
            
            UINib(nibName: lastCellIdentifier, bundle: nil),
            forCellWithReuseIdentifier: lastCellIdentifier
        )
    }

    // MARK: - MULoadControlDelegate

    open func loadControlEmptyItems() -> [MUModel] {

        var array: [MUEmptyModel] = []

        for _ in 0..<loadControlEmptyItemsCount {

            array.append(MUEmptyModel())
        }

        return array
    }
    
    // MARK: - Private methods
    
    @objc private func updateIfNeeded(_ timer: Timer) {
        
        guard !refreshControl.isRefreshing, tableView?.contentOffset.y ?? 0 == 0 else { return }
        
        if let userInfo = timer.userInfo as? [String: [MUModel]], let newObjects = userInfo["newObjects"] {
            
            updateWithoutTimeInterval(objects: newObjects)
        }
        
        timer.invalidate()
    }
    
    private func getObjects() -> [MUModel] {
        
        if tableView != nil {
            
            return tableControl.objects
        } else {
            return collectionControl.objects
        }
    }
    
    private func setObjects(with newObjects: [MUModel]) {
        
        if tableView != nil {
            
            tableControl.objects = newObjects
        } else {
            collectionControl.objects = newObjects
        }
    }

    // MARK: - MUListControlDelegate
    
    open func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String? {
        
        return lastCellIdentifier
    }
    
    open func cellIdentifier(at indexPath: IndexPath) -> String? {
        
        return lastCellIdentifier
    }

    open func cellDidSelected(for object: MUModel) {
        
    }
    
    open func cellDidSelected(for object: MUModel, at indexPath: IndexPath) {
        
    }
    
    open func getSection(for object: MUModel) -> String? {
        
        return ""
    }
    
    open func isObjectChanged(for object: MUModel) -> Bool {
        
        return false
    }
    
    open func objectDidChanged(with objects: [MUModel]) {
        
    }
    
    open func scrollDidScroll(_ scrollView: UIScrollView) {
        
        paginationControl.scroll(with: scrollView)
    }
}

// MARK: - MURefreshControlDelegate

extension MUListController: MURefreshControlDelegate {
    
    public func refreshControlDidRefresh() {
        
        paginationControl.reset()
        
        requestObjects(withIndicator: false)
    }
}

// MARK: - MUPaginationControlDelegate

extension MUListController: MUPaginationControlDelegate {
    
    public func paginationControlDidRequestMore(page: Int) {
        
        requestObjects(withIndicator: false)
    }
}
