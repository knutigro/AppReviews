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



class ItunesService {

    var url : String {
        return self.urlHandler.nextUrl ?? self.urlHandler.initialUrl
    }

    let apId : String
    let storeId : String?
    var updated : NSDate?
    let urlHandler : ItunesUrlHandler
    
    // MARK: - Init & teardown

    init(apId: String, storeId: String?) {
        self.apId = apId
        self.storeId = storeId
        self.urlHandler = ItunesUrlHandler(apId: apId, storeId: storeId)
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
        
        self.urlHandler.updateWithJSON(json["feed"]["link"].arrayValue)
    }
    
    // MARK: - Fetching

    func fetchReviews(url: String, completion: (success: Bool, reviews: [JSON]?, error : NSError?) -> Void) {
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { (request, response, json, error) in
                
                if error != nil {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                    completion(success: false, reviews: nil, error : error)
                } else {
                    var json = JSON(json!)
                    let reviews = json["feed"]["entry"].arrayValue
                    
                    println("found " + String(reviews.count) + " reviews. \(url)" )

                    completion(success: true, reviews: reviews, error : nil)
                    
                    if let nextUrl = self.urlHandler.nextUrl {
                        if reviews.count > 0 {
                            self.updateWithJSON(json)
                            self.fetchReviews(nextUrl, completion: completion)
                        }
                    }
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