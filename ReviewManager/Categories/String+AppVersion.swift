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
        
        let versionComponents = (componentsSeparatedByString("."))
        var versionComponentsAsIntegers = [Int]()
        
        for component in versionComponents {
            
            let range = Range<String.Index>(start: component.startIndex, end: component.endIndex)

            // NSRegularExpressionSearch
            let componentString = component.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: NSStringCompareOptions(rawValue: 1024), range: range)
            if let intComponent = Int(componentString) {
                versionComponentsAsIntegers.append(intComponent)
            }
        }
        
        return versionComponentsAsIntegers
    }
    
    func compareVersion(version: NSString) -> NSComparisonResult {
        
        let myIntegerArray = versionAsIntegerArray()
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
