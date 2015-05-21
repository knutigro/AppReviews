//
//  String+Size.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-23.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit


extension String {
    
    func size(width : CGFloat, font : NSFont) -> NSSize {
        let range =  NSMakeRange(0, (self as NSString).length)
        var size = NSMakeSize(width, CGFloat(MAXFLOAT))
        var textStorage = NSTextStorage(string: self)
        var textContainer = NSTextContainer(containerSize: size)
        var layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textStorage.addAttribute(NSFontAttributeName, value: font, range: range)
        textContainer.lineFragmentPadding = 0.0
        layoutManager.glyphRangeForTextContainer(textContainer)
        
        size.height = layoutManager.usedRectForTextContainer(textContainer).size.height
        
        return size
    }
    
}