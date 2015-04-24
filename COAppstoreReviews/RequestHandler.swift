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

class RequestHandler {
    
    let apId : String
    let storeId : String?
    var updated : NSDate?
    var previousPage : String?
    var nextPage : String?
    var firstPage : String?
    var lastPage : String?
    
    // MARK: - Init & teardown

    init(apId: String, storeId: String?) {
        self.apId = apId
        self.storeId = storeId
    }
    
    // MARK: - Update object
    
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
    }
    
    // MARK: - Fetching

    func fetchReview(completion: (success: Bool, reviews: [JSON]?, error : NSError?) -> Void) {
        let storePath = storeId != nil ? ("/" + storeId!) : ""
        var url = "https://itunes.apple.com" +  storePath + "/rss/customerreviews/id=" + self.apId + "/json"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { [weak self] (request, response, json, error) in
                
                if error != nil {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                    completion(success: false, reviews: nil, error : error)
                } else {
                    var json = JSON(json!)
                    let reviews = json["feed"]["entry"].arrayValue
                    
                    println("found " + String(reviews.count) + " reviews. \(url)" )
                    
                    if let strongSelf = self {
                        strongSelf.updateWithJSON(json)
                    }

                    completion(success: true, reviews: reviews, error : nil)
                }
        }
    }
    
    class func fetchApplications(name: String, completion: (success: Bool, applications: JSON?, error : NSError?) -> Void) {
        
        var url = "https://itunes.apple.com/search"
        let params = ["term": name, "entity" : "software"]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                    completion(success: false, applications: nil, error : error)
                } else {
                    var json = JSON(json!)
                    completion(success: true, applications: json["results"], error : nil)
                    println("found " + name + ". \(url)" )
                }
        }
    }
}