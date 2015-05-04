//
//  NSApplicationDelegate+Version.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//


import AppKit

// MARK: Version

extension NSApplication {
    
    class func v_appVersion() -> String? {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }

    class func v_build() -> String? {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String
    }

    class func v_versionBuild() -> String {
        var versionBuild = ""

        if let version = NSApplication.v_appVersion() {
            versionBuild += String(format: "Version %@", version)
        }

        if let buildString = NSApplication.v_build() {
            versionBuild += String(format: " (%@)", buildString)
        }

        return versionBuild
    }

}