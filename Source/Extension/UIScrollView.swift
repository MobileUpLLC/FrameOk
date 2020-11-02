//
//  UIScrollView.swift

//
//  Created by Dmitry Smirnov on 22.05.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    // MARK: - Public methods
    
    func scrollToBottom(animated: Bool = true) {
        
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        
        setContentOffset(bottomOffset, animated: animated)
    }
}

// MARK: Bottom Offset

extension UIScrollView {

    func setBottomContentOffset(_ offset: CGFloat, animated: Bool) {

        let offset = (contentSize.height - offset) - frame.size.height

        setContentOffset(CGPoint(x: contentOffset.x, y: offset), animated: animated)
    }

    @available (iOS 11.0, *)
    var safeBottomContentInset: CGFloat {

        return adjustedContentInset.bottom - contentInset.bottom
    }
}

// MARK: Horizontal Offset

extension UIScrollView {

    func setXOffset(_ value: CGFloat, animated: Bool) {

        let offset = CGPoint(x: value, y: contentOffset.y)

        setContentOffset(offset, animated: animated)
    }
}

// MARK: Horizontal Paging

extension UIScrollView {

    private func checkForPaging() {

        if isPagingEnabled == false {

            Log.critical("If paging disabled horizontal scroll view extesions may not work as expected")
        }
    }

    var currentHorizontalPage: Int {

        checkForPaging()

        return Int(contentOffset.x / frame.size.width)
    }

    var horizontalPagesCont: Int {

        checkForPaging()

        return Int(contentSize.width / frame.size.width)
    }

    func scrollToHorizontalPage(_ index: Int, animated: Bool) {

        checkForPaging()

        var resultFrame = bounds
        resultFrame.origin.x = frame.size.width * CGFloat(index)

        scrollRectToVisible(resultFrame, animated: animated)
    }
}
