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
    
    var urlHandler : ItunesUrlHandler!
    let kInitialUrl = "https://itunes.apple.com/rss/customerreviews/id=123/json"
    var reviewJSON : JSON!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.urlHandler = ItunesUrlHandler(apId: "123", storeId: nil)
        
        var error : NSError?
        if let path = NSBundle.mainBundle().pathForResource("reviews", ofType: "json") {
            if let string = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: &error) as? String {
                self.reviewJSON = JSON(string)
            }
        }
        if self.reviewJSON == nil {
            XCTFail("reviewJSON Should not be nil")
        }
    }
    
    func testIfLinkExist() {
        let feed = self.reviewJSON[0]

        println("reviewJSON \(self.reviewJSON)")

//        println("reviewJSON \(self.reviewJSON)")
        let reviews1 = self.reviewJSON.itunesReviews

        let reviews = self.reviewJSON.itunesFeedLinks
        println("reviews count = \(reviews)")

//        let count = self.reviewJSON?["feed"]["link"].array?.count
//
//        let count = self.reviewJSON?["feed"]["link"].array?.count
//        println("count \(count)")
//        XCTAssertNotNil(self.reviewJSON?["feed"]["link"].arrayObject, "JSON should have an Array with links")
    }
    
    func testInitialUrl() {
//        self.pages.append(ItunesPage(url: self.initialUrl, page: 0))

        XCTAssertEqual(self.urlHandler.initialUrl, kInitialUrl, "There should be inital url")
    }

    func testPrecedingUrlUrl() {
//        if let json = json {
//            self.urlHandler.updateWithJSON(json["feed"]["link"].arrayValue)
//        } else {
//        }

        println("nextUrl \(self.urlHandler.nextUrl)")
    }
    
    

}
