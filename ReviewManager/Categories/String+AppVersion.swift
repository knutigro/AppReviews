//
//  Application+Version.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-19.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

// AppVersion

extension NSString {
    
    private func versionAsIntegerArray() -> [Int] {
        let versionComponents = (self.componentsSeparatedByString("."))
        var versionComponentsAsIntegers = [Int]()
        
        for component in versionComponents {
            // NSRegularExpressionSearch
            let componentString = component.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: NSStringCompareOptions(1024), range: NSMakeRange(0, component.length))
            if let intComponent = componentString.toInt() {
                versionComponentsAsIntegers.append(intComponent)
            }
        }
        
        return versionComponentsAsIntegers
    }
    
    func compareVersion(version: NSString) -> NSComparisonResult {
        
        let myIntegerArray = self.versionAsIntegerArray()
        let applicationArray = version.versionAsIntegerArray()
        
        for (var i = 0; i < myIntegerArray.count; i++) {
            let myVersion = myIntegerArray[i]
            let applicationVersion = i < applicationArray.count ? applicationArray[i]: 0
            if myVersion > applicationVersion {
                return .OrderedDescending
            } else if myVersion < applicationVersion {
                return .OrderedAscending
            }
        }
        
        return .OrderedSame
    }
}
