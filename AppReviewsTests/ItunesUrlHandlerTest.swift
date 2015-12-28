//
//  ItunesUrlHandlerTest.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-15.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

import Cocoa
import XCTest
import SwiftyJSON

class ItunesUrlHandlerTest: XCTestCase {
    
    var urlHandler: ItunesUrlHandler!
    let kInitialUrl = "https://itunes.apple.com/rss/customerreviews/id=123/json"
    var reviewJSON: JSON!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        urlHandler = ItunesUrlHandler(apId: "123", storeId: nil)
        
        if let path = NSBundle.mainBundle().pathForResource("reviews", ofType: "json") {
            do {
                let string = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                reviewJSON = JSON(string)
            } catch {
                print("Failed at try")
            }
        }
        if reviewJSON == nil {
            XCTFail("reviewJSON Should not be nil")
        }
    }
    
    func testIfLinkExist() {
        _ = reviewJSON[0]

        print("reviewJSON \(reviewJSON)")

//        println("reviewJSON \(reviewJSON)")
        _ = reviewJSON.itunesReviews

        let reviews = reviewJSON.itunesFeedLinks
        print("reviews count = \(reviews)")

//        let count = reviewJSON?["feed"]["link"].array?.count
//
//        let count = reviewJSON?["feed"]["link"].array?.count
//        println("count \(count)")
//        XCTAssertNotNil(reviewJSON?["feed"]["link"].arrayObject, "JSON should have an Array with links")
    }
    
    func testInitialUrl() {
//        pages.append(ItunesPage(url: initialUrl, page: 0))

        XCTAssertEqual(urlHandler.initialUrl, kInitialUrl, "There should be inital url")
    }

    func testPrecedingUrlUrl() {
//        if let json = json {
//            urlHandler.updateWithJSON(json["feed"]["link"].arrayValue)
//        } else {
//        }

        print("nextUrl \(urlHandler.nextUrl)")
    }
    
    

}
