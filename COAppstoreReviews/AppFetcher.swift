//
//  COApplicationFetcher.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class AppFetcher {
    
    func fetchApplications(name: String, completion: (success: Bool, applications: JSON?, error : NSError?) -> Void) {
        
        var url = "https://itunes.apple.com/search"
        let params = ["term": name, "entity" : "software"]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { [weak self] (request, response, json, error) in
                
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                    completion(success: false, applications: nil, error : error)
                } else {
                    var json = JSON(json!)
                    completion(success: true, applications: json["results"], error : nil)
                }
        }
    }
    
}