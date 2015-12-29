//
//  NSUserDefaults+AppReviews.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-28.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

// AppReviews extension

extension NSUserDefaults {
    
    class func review_shouldShowLaunchScreen() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey("ShouldNotShowLaunchScreen")
    }
    
    class func review_setShouldShowLaunchScreen(show : Bool) {
        NSUserDefaults.standardUserDefaults().setBool(!show, forKey: "ShouldNotShowLaunchScreen")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func review_isFirstLaunch() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey("DidRun")
    }
    
    class func review_setDidLaunch() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "DidRun")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}