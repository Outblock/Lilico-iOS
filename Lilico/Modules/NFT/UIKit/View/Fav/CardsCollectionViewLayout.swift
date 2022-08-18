//
//  CardsCollectionViewLayout.swift
//  CardsExample
//
//  Created by Filipp Fediakov on 18.08.17.
//  Copyright © 2017 filletofish. All rights reserved.
//

import UIKit

open class CardsCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - Layout configuration
    
    public var itemSize: CGSize = CGSize(width: 200, height: 300) {
        didSet{
            invalidateLayout()
        }
    }
    
    public var spacing: CGFloat {
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        if totalItemsCount == 1 {
            return 0
        }
        
        var totalSpacingWidth = collectionView.bounds.width - 18 * 2
        
        if totalItemsCount >= 4 {
            let itemWidth = itemSize.width * scale(at: 0)
            totalSpacingWidth -= itemWidth
            
            totalSpacingWidth += (itemWidth - itemSize.width * scale(at: 1)) / 2.0
            totalSpacingWidth += (itemWidth - itemSize.width * scale(at: 2)) / 2.0
            
            return totalSpacingWidth / CGFloat((maximumVisibleItems - 2))
        } else {
            let itemWidth = itemSize.width * scale(at: 0)
            
            for i in 0..<totalItemsCount {
                if i == 0 {
                    totalSpacingWidth -= itemWidth
                    continue
                }
                
                let perOffset = (itemWidth - itemSize.width * scale(at: i)) / 2.0
                totalSpacingWidth += perOffset
            }
            
            return totalSpacingWidth / CGFloat(totalItemsCount - 1)
        }
    }
    
    public var maximumVisibleItems: Int = 5 {
        didSet{
            invalidateLayout()
        }
    }
    
    // MARK: UICollectionViewLayout
    
    override open var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    override open var collectionViewContentSize: CGSize {
        let itemsCount = CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: collectionView.bounds.width * itemsCount,
                      height: collectionView.bounds.height)
    }
    
    override open func prepare() {
        super.prepare()
        assert(collectionView.numberOfSections == 1, "Multiple sections aren't supported!")
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        
        let minVisibleIndex = max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
        let maxVisibleIndex = min(minVisibleIndex + maximumVisibleItems, totalItemsCount)
        
        let scale = scale(at: 0)
        var moreOffsetX = (collectionView.bounds.width - itemSize.width * scale) / 2.0 - 18
        
        if totalItemsCount == 1 {
            moreOffsetX = 0
        }
        
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0) - moreOffsetX
        
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        
        let visibleIndices = stride(from: minVisibleIndex, to: maxVisibleIndex, by: 1)
        
        let attributes: [UICollectionViewLayoutAttributes] = visibleIndices.map { index in
            let indexPath = IndexPath(item: index, section: 0)
            return computeLayoutAttributesForItem(indexPath: indexPath,
                                                  minVisibleIndex: minVisibleIndex,
                                                  contentCenterX: contentCenterX,
                                                  deltaOffset: CGFloat(deltaOffset),
                                                  percentageDeltaOffset: percentageDeltaOffset)
        }
        
        return attributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        
        let scale = scale(at: 0)
        var moreOffsetX = (collectionView.bounds.width - itemSize.width * scale) / 2.0 - 18
        
        if totalItemsCount == 1 {
            moreOffsetX = 0
        }
        
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0) - moreOffsetX
        let minVisibleIndex = Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        return computeLayoutAttributesForItem(indexPath: indexPath,
                                              minVisibleIndex: minVisibleIndex,
                                              contentCenterX: contentCenterX,
                                              deltaOffset: CGFloat(deltaOffset),
                                              percentageDeltaOffset: percentageDeltaOffset)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


// MARK: - Layout computations

fileprivate extension CardsCollectionViewLayout {
    
    private func scale(at index: Int) -> CGFloat {
        switch index {
        case 0:
            return 1
        case 1:
            return 0.9
        case 2:
            return 0.8
        case 3:
            return 0.7
        default:
            return 0.6
        }
//        let translatedCoefficient = CGFloat(index) - CGFloat(self.maximumVisibleItems) / 2
//        return CGFloat(pow(0.95, translatedCoefficient))
    }
    
    private func transform(atCurrentVisibleIndex visibleIndex: Int, percentageOffset: CGFloat) -> CGAffineTransform {
        var rawScale = visibleIndex < maximumVisibleItems ? scale(at: visibleIndex) : 1.0
        
        if visibleIndex != 0 {
            let previousScale = scale(at: visibleIndex - 1)
            let delta = (previousScale - rawScale) * percentageOffset
            rawScale += delta
        }
        
        return CGAffineTransform(scaleX: rawScale, y: rawScale)
    }
    
    fileprivate func computeLayoutAttributesForItem(indexPath: IndexPath,
                                                    minVisibleIndex: Int,
                                                    contentCenterX: CGFloat,
                                                    deltaOffset: CGFloat,
                                                    percentageDeltaOffset: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath)
        let visibleIndex = indexPath.row - minVisibleIndex
        attributes.size = itemSize
        let midY = self.collectionView.bounds.midY
        attributes.center = CGPoint(x: contentCenterX + spacing * CGFloat(visibleIndex),
                                    y: midY)
        attributes.zIndex = maximumVisibleItems - visibleIndex
        
        attributes.transform = transform(atCurrentVisibleIndex: visibleIndex,
                                         percentageOffset: percentageDeltaOffset)
        switch visibleIndex {
        case 0:
            attributes.center.x -= deltaOffset
            break
        case 1..<maximumVisibleItems:
            attributes.center.x -= spacing * percentageDeltaOffset
            //      attributes.center.y -= spacing * percentageDeltaOffset
            
            
            if visibleIndex == maximumVisibleItems - 1 {
                attributes.alpha = percentageDeltaOffset
            }
            break
        default:
            attributes.alpha = 0
            break
        }
        return attributes
    }
}
