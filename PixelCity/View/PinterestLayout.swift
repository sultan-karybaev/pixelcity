//
//  PinterestLayout.swift
//  PixelCity
//
//  Created by Sultan Karybaev on 10/28/18.
//  Copyright © 2018 Sultan Karybaev. All rights reserved.
//

import UIKit

class PinterestLayout: UICollectionViewLayout {
    var numberOfColumns: CGFloat = 3
    var cellPadding: CGFloat = 1
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return (collectionView!.bounds.width - (insets.left + insets.right))
    }
    
    private var attributesCache = [PinterestLayoutAttributes]()
    
    override func prepare() {
        attributesCache = []
        print("prepare \(attributesCache.count)")
        if collectionView!.numberOfItems(inSection: 0) == 0 {
            contentHeight = 0
        }
        //if attributesCache.isEmpty {
            print("attributesCache.isEmpty \(collectionView!.numberOfItems(inSection: 0))")
            let columnWidth = contentWidth / numberOfColumns
            var xOffsets = [CGFloat]()
            for column in 0 ..< Int(numberOfColumns) {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var yOffsets = [CGFloat](repeating: 0, count: Int(numberOfColumns))
            
            //-----
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                //print("item \(indexPath)")
                
                // calculate the frame
                let width = columnWidth - cellPadding * 2
                let photoHeight: CGFloat
                if item != 1 {
                    photoHeight = width / 9 * 16
                } else {
                    photoHeight = width / 9 * 8
                }
                
                let height: CGFloat = photoHeight + cellPadding * 2
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // create layout attributes
                let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                attributesCache.append(attributes)
                
                // update column, yOffset
                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = yOffsets[column] + height
                
                if column >= (Int(numberOfColumns) - 1) {
                    column = 0
                } else {
                    column += 1
                }
            }
        //}
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in attributesCache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override func invalidateLayout() {
        print("invalidateLayout")
        super.invalidateLayout()
    }
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes
{
    var photoHeight: CGFloat = 0.0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        
        return false
    }
}
