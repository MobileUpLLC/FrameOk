//
//  MUCollectionControl.swift

//
//  Created by Dmitry Smirnov on 02/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUCollectionControl

open class MUCollectionControl: NSObject {
    
    // MARK: - Public properties
    
    open weak var controller: MUListController?
    
    open weak var delegate: MUListControlDelegate?
    
    open weak var collectionView: UICollectionView?
    
    open var isEnabled: Bool = false

    open var numberOfColumns: Int = 1
    
    open var objects: [MUModel] = [] { didSet { updateObjects() } }
    
    open var flow: UICollectionViewFlowLayout? { return (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout) }
    
    // MARK: - Public methods
    
    open func setup(with controller: MUListController) {
        
        collectionView = controller.collectionView
        
        collectionView?.delegate = self
        
        collectionView?.dataSource = self
        
        delegate = controller
        
        self.controller = controller
    }
    
    // MARK: - Private methods
    
    private func updateObjects() {
        
        collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension MUCollectionControl:
    
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return delegate?.collectionView?(collectionView, numberOfItemsInSection: section) ?? objects.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = delegate?.collectionView?(collectionView, cellForItemAt: indexPath) {
            
            return cell
        }
        
        let object = objects[indexPath.row]
        
        let cellIdentifier = delegate?.cellIdentifier(for: object, at: indexPath) ?? "Cell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        (cell as? MUCollectionCell)?.setup(with: object, sender: controller)
        
        return cell
    }
    
    public func collectionView(
        
        _ collectionView                       : UICollectionView,
        layout collectionViewLayout            : UICollectionViewLayout,
        minimumLineSpacingForSectionAt section : Int) -> CGFloat
        
    {
        let spacing = delegate?.collectionView?(collectionView, layout: collectionViewLayout, section: section)
        
        return spacing ?? CGFloat(flow?.minimumInteritemSpacing ?? 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let didSelect = delegate?.collectionView(_:didSelectItemAt:) {
            
            didSelect(collectionView, indexPath)
            
        } else {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? MUCollectionCell else {
                
                return Log.error("error: could not find cell for indexPath \(indexPath)")
            }
            
            guard let object = cell.object else {
                
                return Log.error("error: cell object is nil")
            }

            delegate?.cellDidSelected(for: object)
            
            delegate?.cellDidSelected(for: object, at: indexPath)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        return collectionView.dequeueReusableSupplementaryView(
            
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header",
            for: indexPath
        )
    }
}

// MARK: - UIScrollViewDelegate

extension MUCollectionControl: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.scrollDidScroll(scrollView)
    }
}

// MARK: - MUCollectionCell

open class MUCollectionCell: UICollectionViewCell {
    
    open var object: MUModel?
    
    open func setup(with object: MUModel, sender: Any? = nil) {
        
        self.object = object
    }
}
