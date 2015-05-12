//
//  AutomaticUpdateTransformer.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

@objc(AutomaticUpdateTransformer)
class AutomaticUpdateTransformer : NSValueTransformer{
    
//    override class func transformedValueClass() -> AnyClass {
//        return NSNumber.self
//    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject? {
        if let on = value as? Bool {
//            return on ? NSOffState : NSOnState
            return on ? NSOnState : NSOffState
//            return on ? NSNumber(integer: NSOnState) :  NSNumber(integer: NSOffState)
        } else {
            return nil
        }
    }
}