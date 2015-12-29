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
    var reviewJSON: JSON?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        urlHandler = ItunesUrlHandler(apId: "123", storeId: nil)
        
        if let path = NSBundle(forClass: ItunesUrlHandlerTest.self).pathForResource("reviews", ofType: "json") {
            do {
                let string = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                if let dataFromString = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    reviewJSON = JSON(data: dataFromString)
                }
            } catch {
                XCTFail("contentsOfFile did fail")
            }
        }
        XCTAssertNotNil(reviewJSON)
    }
    
    func testIfFeedExist() {
        guard let reviewJSON = self.reviewJSON else {
            return
        }
        
        XCTAssertNotNil(reviewJSON.itunesFeed)
    }
    
    func testIfReviewsExist() {
        guard let reviewJSON = self.reviewJSON else {
            return
        }
        
        XCTAssertNotNil(reviewJSON.itunesReviews)
        XCTAssertGreaterThan(reviewJSON.itunesReviews.count, 0)
    }
    
    func testIfLinkExist() {
        guard let reviewJSON = self.reviewJSON else {
            return
        }
        XCTAssertGreaterThan(reviewJSON.itunesFeedLinks.count, 0)
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
