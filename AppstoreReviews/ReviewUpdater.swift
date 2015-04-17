//
//  ReviewUpdater.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-18.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

// Update interval in seconds
let UpdateInterval = 0.5

class ReviewUpdater {
    
    class ApplicationUpdateObject {
        
    }
    
    var timer: Timer?
    var applications = [ApplicationUpdateObject]()
    
    // MARK: - Init & teardown
    
    init() {
        self.timer = Timer.repeatEvery(UpdateInterval) { [weak self] inTimer in
            if let strongSelf = self {
                //                strongSelf.updateStatusItem()
            }
        }
    }

    
}
