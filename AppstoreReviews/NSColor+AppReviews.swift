//
//  NSColor+AppReviews.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//


extension NSColor {

    class func reviewRed() -> NSColor {
        return NSColor(deviceRed: 0.941, green: 0.306, blue: 0.314, alpha: 1)
    }

    class func reviewOrange() -> NSColor {
        return NSColor(deviceRed: 0.992, green: 0.522, blue: 0.224, alpha: 1)
    }

    class func reviewYellow() -> NSColor {
        return NSColor(deviceRed: 0.992, green: 0.741, blue: 0.239, alpha: 1)
    }

    class func reviewBlue() -> NSColor {
        return NSColor(deviceRed: 0.404, green: 0.608, blue: 0.788, alpha: 1)
    }

    class func reviewGreen() -> NSColor {
        return NSColor(deviceRed: 0.353, green: 0.788, blue: 0.765, alpha: 1)
    }
}

