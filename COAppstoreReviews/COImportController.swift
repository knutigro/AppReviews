//
//  COImportController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit
import SwiftyJSON

class COImportController {
    let context : NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func importReviews(apId: String, storeId: String?) {
        // [unowned self]
        
        let reviewFetcher = COReviewFetcher(apId: apId, storeId: storeId)
        
        reviewFetcher.fetchReview() {
            (success: Bool, reviews: JSON?, error : NSError?)
             in

            let blockSuccess = success as Bool
            let blockError = error

            self.context.performBlock({ () -> Void in
                
                if let blockReviews = reviews {
                    
                    for var index = 0; index < blockReviews.count; index++ {
                        let entry = blockReviews[index]
                        
                        if let identifier = entry.applicationIdentifier {
                            if Application.findEntryWithIdentifier(identifier, context: self.context) == nil {
                                Application(json: entry, insertIntoManagedObjectContext: self.context)
                            }
                        } else if let identifier = entry.reviewIdentifier {
                            if Review.findEntryWithIdentifier(identifier, context: self.context) == nil {
                                Review(json: entry, insertIntoManagedObjectContext: self.context)
                            }
                        }
                    }
                    
                    var error : NSError? = nil
                    self.context.save(&error)
                    
                    if error != nil {
                        println("error: " + error!.localizedDescription)
                    }
                }

            })
        }
    }

}
