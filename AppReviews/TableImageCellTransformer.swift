//
//  TableImageCellTransformer.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-14.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

@objc(TableImageCellTransformer)
class TableImageCellTransformer: NSValueTransformer{
    
    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject? {
        guard let value = value as? String, let url = NSURL(string: value) else {
            return nil
        }
        
        return NSImage(contentsOfURL: url)
    }
}