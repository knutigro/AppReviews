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

class ImportController {
    let context : NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func importReviews(apId: String, storeId: String?) {
        // [unowned self]
        
        let reviewFetcher = ReviewFetcher(apId: apId, storeId: storeId)
        
        reviewFetcher.fetchReview() {
            (success: Bool, reviews: JSON?, error : NSError?)
             in

            let blockSuccess = success as Bool
            let blockError = error

            self.context.performBlock({ () -> Void in
                
                if let blockReviews = reviews {
                    
                    for var index = 0; index < blockReviews.count; index++ {
                        let entry = blockReviews[index]
                        
                        if entry.isReviewEntity, let apID = entry.reviewApID {
                            var review = Review.findOrCreateNewReview(apID, context: self.context)
                            review.updateWithJSON(entry)
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
