//
//  COReviewFetcher.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ReviewFetcher {
    
    let apId : String?
    let storeId : String?
    
    var updated : NSDate?
    var previousPage : String?
    var nextPage : String?
    var firstPage : String?
    var lastPage : String?
    
    init(apId: String, storeId: String?) {
        self.apId = apId
        self.storeId = storeId
    }
    
    func updateWithJSON(json : JSON) {
        
        if let dateString = json["feed"]["updated"]["label"].string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:SS'"
            if let date = dateFormatter.dateFromString(dateString) {
                self.updated = date
            }
        }
        
        let linkArray = json["feed"]["link"].arrayValue
        
        for jsonLink in linkArray {
            let attributes = jsonLink["attributes"]
            if attributes["rel"].stringValue == "last" {
                self.lastPage = attributes["href"].string
            } else if attributes["rel"].stringValue == "first" {
                self.firstPage = attributes["href"].string
            } else if attributes["rel"].stringValue == "previous" {
                self.previousPage = attributes["href"].string
            } else if attributes["rel"].stringValue == "next" {
                self.nextPage = attributes["href"].string
            }
        }
        
        println("updated \(updated)")
        println("lastPage \(lastPage)")
        println("firstPage \(firstPage)")
        println("previousPage \(previousPage)")
        println("nextPage \(nextPage)")
    }
    
    func fetchReview(completion: (success: Bool, reviews: JSON?, error : NSError?) -> Void) {
        
        self.fakeFetchReview(completion)
        return

//        let storePath = storeId != nil ? ("/" + storeId!) : ""
//        var url = "https://itunes.apple.com" +  storePath + "/rss/customerreviews/id=" + appId + "/json"
//        
//        let params = ["foo": "bar"]
//        
//        println(url)
//        
//        Alamofire.request(.GET, url, parameters: nil)
//            .responseJSON { (request, response, json, error) in
//                
//                if(error != nil) {
//                    NSLog("Error: \(error)")
//                    println(request)
//                    println(response)
//        updateWithJSON(json)
//                    completion(success: false, reviews: nil, error : error)
//                } else {
//                    var json = JSON(json!)
//                    let reviews = json["feed"]["entry"]

//                    completion(success: true, reviews: reviews, error : nil)
//                }
//        }
    }
    
    func fakeFetchReview(completion: (success: Bool, reviews: JSON?, error : NSError?) -> Void) {
        if let path = NSBundle.mainBundle().pathForResource("reviews", ofType: "json") {
            if let data = NSData(contentsOfMappedFile: path) {
                var error : NSError? = nil
                let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                
                if error != nil {
                    println("error: \(error?.localizedDescription)")
                }
                
                updateWithJSON(json)
                let reviews = json["feed"]["entry"]

                completion(success: true, reviews: reviews, error : error)
            }
        }
    }
}