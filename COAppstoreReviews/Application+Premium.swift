//
//  Application+Premium.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

let isPremiumLimitationsActivated = true

// MARK: Extensions for PremiumContent

extension ApplicationUpdater {
    
    var canAddApplication : (result: Bool, description: String?) {
       let  isPremiumUser = !InAppPurchaseManager.sharedInstance.isPremiumUser()
        if isPremiumUser {
            return (true, nil)
        } else if isPremiumLimitationsActivated  && self.numberOfMonitoredApplications > 0 {
            return (false, NSLocalizedString("Non premium users is limited to one application. Premium users have no limitations.", comment: "premium.limitation.numberofapplications"))
        } else {
            return (true, nil)
        }
    }
}