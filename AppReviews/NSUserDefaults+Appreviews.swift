//
//  NSUserDefaults+Appreviews.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

extension NSUserDefaults {
    
    class func setPremiumUser(premium: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(premium, forKey: "kInAppPurchaseContentPremium")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    class func isPremiumUser() -> Bool  {
        return NSUserDefaults.standardUserDefaults().boolForKey("kInAppPurchaseContentPremium");
    }


}
