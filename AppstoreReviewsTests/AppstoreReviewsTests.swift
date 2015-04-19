//
//  AppstoreReviewsTests.swift
//  AppstoreReviewsTests
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import XCTest
//import SwiftyJSON

class AppstoreReviewsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
        
//        var application1 = Application()
//        application1.version = "1.2.3"
//
//        var application2 = Application()
//        application2.version = "1.2.4"
//
//        var applicationArray = [application1, application2]
//        
//        let sortDescriptors1 = [NSSortDescriptor(key: "version", ascending: false), NSSortDescriptor(key: "createdAt", ascending: true)]
//
//        let sortDescriptors2 = [NSSortDescriptor(key: "version", ascending: false, selector: Selector("compareVersion:toVersion:"))]
//        
//        var sortedArray = NSArray(array: applicationArray).sortedArrayUsingDescriptors(sortDescriptors1)
//        
//        println("\(sortedArray)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
