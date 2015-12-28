//
//  COReviewFetcher.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON



class ItunesService {

    var url: String {
        return urlHandler.nextUrl ?? urlHandler.initialUrl
    }

    let apId: String
    let storeId: String?
    var updated: NSDate?
    let urlHandler: ItunesUrlHandler
    
    // MARK: - Init & teardown

    init(apId: String, storeId: String?) {
        self.apId = apId
        self.storeId = storeId
        urlHandler = ItunesUrlHandler(apId: apId, storeId: storeId)
    }
    
    // MARK: - Update object
    
    func updateWithJSON(json: JSON) {
        
        if let dateString = json.itunesReviewsUpdatedAt {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:SS'"
            if let date = dateFormatter.dateFromString(dateString) {
                updated = date
            }
        }
        
        urlHandler.updateWithJSON(json.itunesFeedLinks)
    }
    
    // MARK: - Fetching

    func fetchReviews(url: String, completion: (success: Bool, reviews: [JSON]?, error: NSError?) -> Void) {
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                
                if response.result.error != nil {
                    NSLog("Error: \(response.result.error)")
                    print(response.request)
                    print(response)
                    completion(success: false, reviews: nil, error: response.result.error)
                } else {
                    let json = JSON(response.result.value!)
                    let reviews = json.itunesReviews
                    
                    completion(success: true, reviews: reviews, error: nil)
                    
                    // TODO: THIS WILL ALLWAYS FAIL SINCE nexturl is nil from the first round
                    if let nextUrl = self.urlHandler.nextUrl {
                        if reviews.count > 0 {
                            self.updateWithJSON(json)
                            self.fetchReviews(nextUrl, completion: completion)
                        }
                    }
                }
        }
    }
    
    class func fetchApplications(name: String, completion: (success: Bool, applications: JSON?, error: NSError?) -> Void) {
        
        let url = "https://itunes.apple.com/search"
        let params = ["term": name, "entity": "software"]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { response in
                
                if(response.result.error != nil) {
                    NSLog("Error: \(response.result.error)")
                    print(response.request)
                    print(response)
                    completion(success: false, applications: nil, error: response.result.error)
                } else {
                    var json = JSON(response.result.value!)
                    completion(success: true, applications: json["results"], error: nil)
                }
        }
    }
}

// MARK: Extension for reviewFeed

extension JSON {
    var itunesReviews: [JSON] { return self["feed"]["entry"].arrayValue }
    var itunesReviewsUpdatedAt: String? { return self["feed"]["updated"]["label"].string }
    var itunesFeedLinks: [JSON] { return self["feed"]["link"].arrayValue }
}



