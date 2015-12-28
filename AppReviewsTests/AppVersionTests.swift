//
//  AppVersionTests.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-15.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import XCTest

class AppVersionTests: XCTestCase {
    
    func testVersionSortDecriptor() {
        // This is an example of a functional test case.
        
        let version0 = "0.2.4"
        let version1 = "1.2.3"
        let version2 = "1.2"
        let version3 = "1.beta3.4"
        let version4 = "1.3.4.5"
        let version5 = "2.0"
        let version6 = "2.beta1"
        
        let test1 = [version0, version1, version2, version3, version4, version0, version5, version6]
        let test2 = [version6, version5, version4, version3, version2, version1, version0, version0]
        
        let sortDescriptors = [NSSortDescriptor(key: "self", ascending: true, selector: Selector("compareVersion:"))]
        
        let sortedArray1 = NSArray(array: test1).sortedArrayUsingDescriptors(sortDescriptors)
        let sortedArray2 = NSArray(array: test2).sortedArrayUsingDescriptors(sortDescriptors)
        
        XCTAssertEqual(sortedArray1.first as? String, sortedArray2.first as? String, "The two first versions should be the same")
        XCTAssertEqual(sortedArray1.last as? String, version6, "The biggest version is 2.beta1")
        
        print("sortedArray1 \(sortedArray1)")
        print("sortedArray2 \(sortedArray2)")
    }
    
}
