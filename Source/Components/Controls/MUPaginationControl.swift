//
//  MUPaginationControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: MUActivityIndicator

public protocol MUActivityIndicator: Any {

    func startAnimating()
    
    func stopAnimating()
}

// MARK: - MUPaginationControlDelegate

public protocol MUPaginationControlDelegate: class {
    
    func paginationControlDidRequestMore(page: Int)
}

// MARK: - MUPaginationControl

open class MUPaginationControl: NSObject {
    
    // MARK: - Public properties
    
    open weak var delegate: MUPaginationControlDelegate?
    
    open weak var targetView: UIScrollView?
    
    open weak var tableControl: MUTableControl?
    
    open var page = 1 { didSet { tryRequestMore() } }
    
    open var lastPage: Int?
    
    open var isLoading: Bool = false
    
    open var isLightIndicator: Bool = false
    
    open var isEnabled: Bool = false
    
    open var hasMoreObjects: Bool = true

    open var indicatorView: (UIView & MUActivityIndicator)?

    open var indicatorDelay: TimeInterval = 0.1

    open var isAutoStopAnimation: Bool = true
    
    // MARK: - Private properties
    
    private var isTableControlAnimated: Bool = false
    
    private var initialInsetBottom: CGFloat = 0
    
    private var lastVerticalOffset: CGFloat = 0
    
    private var bottomActivityIndicator: MUBottomActivityIndicator?
    
    private var timer: Timer?
    
    private var isDeleting: Bool = false

    // MARK: - Public methods
    
    open func setup(with controller: MUListController) {
        
        guard controller.hasPagination else { return }

        isEnabled = true
        
        delegate = controller
        
        targetView = controller.tableView ?? controller.collectionView
        
        tableControl = controller.tableControl
        
        isTableControlAnimated = tableControl?.isAnimated ?? false
    }
    
    open func reset() {
        
        page = 1
        
        hasMoreObjects = true
    }
    
    open func cancelLastPage() {
        
        if let lastPage = lastPage {
            
            page = lastPage
            
            self.lastPage = nil
        }
    }
    
    open func startAnimation() {
        
        isLoading = true
        
        tableControl?.isAnimated = false
        
        createIndicator(withDelay: indicatorDelay)
    }

    open func stopAnimationIfNeeded() {

        guard isAutoStopAnimation else {

            return isLoading = false
        }

        stopAnimation()
    }
    
    open func stopAnimation() {
        
        isLoading = false
        
        tableControl?.isAnimated = isTableControlAnimated
        
        removeIndicator()
    }
    
    open func scroll(with scrollView: UIScrollView) {
        
        guard scrollView.contentOffset.y > 0 else { return }
        
        guard isEnabled, hasMoreObjects else { return }
        
        bottomActivityIndicator?.updateHeight(with: scrollView)
        
        guard isLoading == false else { return }
        
        let isScrollDown = lastVerticalOffset < scrollView.contentOffset.y

        lastVerticalOffset = scrollView.contentOffset.y
        
        if isScrollDown && checkNextPage(with: scrollView) {

            lastPage = page

            startAnimation()

            page += 1
        }
    }
    
    // MARK: - Pagination
    
    private func tryRequestMore() {
        
        guard page > 1, let lastPage = lastPage, lastPage < page else { return }
        
        delegate?.paginationControlDidRequestMore(page: page)
    }
    
    fileprivate func checkNextPage(with scrollView: UIScrollView, triggerArea: CGFloat = 60) -> Bool {
        
        guard isLoading == false else { return false }
        
        return scrollView.getOffsetFromBottom() < triggerArea
    }
    
    private func createIndicator(withDelay delay: TimeInterval) {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(createIndicator(with:)), userInfo: nil, repeats: false)
    }
    
    @objc private func createIndicator(with timer: Timer? = nil) {
        
        guard let targetView = targetView, self.bottomActivityIndicator == nil else { return }
        
        guard isDeleting == false else { return }
        
        bottomActivityIndicator?.containerView?.removeFromSuperview()
        
        self.bottomActivityIndicator = getIndicator(in: targetView)

        makeBottomInset(in: targetView)
    }

    private func getIndicator(in targetView: UIView) -> MUBottomActivityIndicator {

        let indicator = indicatorView ?? getDefaultIndicatorView()

        let bottomIndicator = MUBottomActivityIndicator()

        bottomIndicator.append(indicator: indicator, to: targetView, lightStyle: isLightIndicator)

        return bottomIndicator
    }

    private func makeBottomInset(in targetView: UIScrollView) {

        if initialInsetBottom == 0 {

            initialInsetBottom = targetView.contentInset.bottom
        }

        targetView.contentInset.bottom = MUBottomActivityIndicator.bottomInset

        if targetView.isDecelerating == false {

            let height = targetView.contentSize.height - targetView.frame.height

            let contentOffset = CGPoint(x: 0, y: height + MUBottomActivityIndicator.bottomInset)

            targetView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    private func removeIndicator() {

        if isDeleting || bottomActivityIndicator == nil { return }
        
        bottomActivityIndicator?.containerView?.fadeOut()
        
        isDeleting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            
            self?.timer?.invalidate()
            
            self?.bottomActivityIndicator?.containerView?.removeFromSuperview()
            
            self?.bottomActivityIndicator = nil
            
            self?.targetView?.contentInset.bottom = self?.initialInsetBottom ?? 0
            
            self?.isDeleting = false
        }
    }

    private func getDefaultIndicatorView() -> UIView & MUActivityIndicator {

        let indicator = UIActivityIndicatorView()

        if isLightIndicator {

            indicator.style = .white
        } else {
            indicator.style = .gray
        }

        return indicator
    }
}

// MARK: - UIScrollView

public extension UIScrollView {
    
    func getOffsetFromBottom() -> CGFloat {
        
        return contentSize.height - contentOffset.y - frame.height
    }
}

// MARK: - MUBottomActivityIndicator

open class MUBottomActivityIndicator {
    
    // MARK: - Public properties
    
    public static var bottomInset: CGFloat = 60
    
    public static var animationDuration: TimeInterval = 0.3
    
    open weak var containerView: UIView?

    // MARK: - Public methods
    
    open func append(indicator: UIView & MUActivityIndicator, to view: UIView, lightStyle: Bool) {
        
        guard let superview = view.superview, self.containerView == nil else { return }

        // Setup container view
        
        let containerView = UIView()
        
        containerView.clipsToBounds = true
        
        view.superview?.insertSubview(containerView, aboveSubview: view)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        if #available(iOS 11.0, *) {
            
            containerView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            containerView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        }
        
        containerView.heightAnchor.constraint(equalToConstant: 0).isActive = true

        self.containerView = containerView

        // Setup indicator view

        indicator.startAnimating()

        containerView.layoutCenter(indicator)
    }
    
    open func updateHeight(with scrollView: UIScrollView) {
        
        let offsetFromBottom = scrollView.getOffsetFromBottom()
        
        guard offsetFromBottom <= 0 else { return }

        if #available(iOS 11.0, *) {

            let height = abs(offsetFromBottom) - scrollView.safeBottomContentInset

            containerView?.setConstraint(type: .height, value: height)

        } else {

            containerView?.setConstraint(type: .height, value: abs(offsetFromBottom))
        }
    }
}

// MARK: UIActivityIndicatorView + MUActivityIndicator

extension UIActivityIndicatorView: MUActivityIndicator { }
