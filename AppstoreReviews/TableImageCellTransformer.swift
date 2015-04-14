//
//  TableImageCellTransformer.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-14.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

@objc(TableImageCellTransformer)
class TableImageCellTransformer : NSValueTransformer{
    
    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject? {
        if let value = value as? String {
            if let url = NSURL(string: value) {
                let image = NSImage(contentsOfURL: url)
                return image
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}