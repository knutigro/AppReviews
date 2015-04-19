//
//  ReviewArrayController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-11.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewArrayController : NSArrayController {
    
    var application : Application? {
        didSet {
            if let application = self.application {
                self.filterPredicate = NSPredicate(format: "application = %@", application)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false), NSSortDescriptor(key: "createdAt", ascending: true)]
        
//        NSSortDescriptor(key: <#String#>, ascending: <#Bool#>, comparator: <#NSComparator##(AnyObject!, AnyObject!) -> NSComparisonResult#>)
        
//        self.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false, selector: Selector("compareVersion:toVersion:"))]
    }
}
