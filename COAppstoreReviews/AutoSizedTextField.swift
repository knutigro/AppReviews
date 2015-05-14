//
//  NSTextField+Size.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-20.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class AutoSizedTextField : NSTextField {
    
    override var intrinsicContentSize: NSSize {
        get {
            if self.cell()?.wraps == nil{
                return super.intrinsicContentSize
            }
            
            var frame = self.frame
            let width = frame.size.width
            
            // Make the frame very high, while keeping the width
            frame.size.height = CGFloat.max
            
            // Calculate new height within the frame
            // with practically infinite height.
            
            let height = self.cell()?.cellSizeForBounds(frame).height
            
            return NSMakeSize(width, height!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.invalidateIntrinsicContentSize()
    }
    
    override func textDidChange(notification: NSNotification) {
        super.textDidChange(notification)
        self.invalidateIntrinsicContentSize()
    }
}


extension NSTextFieldCell {

    func scaleToAspectFit(source: CGSize, into: CGSize,  padding: CGFloat) -> CGFloat {
        let width = (into.width  - padding) / source.width
        let height = (into.height  - padding) / source.height

        return min(width, height)
    }

    func scaleToAspectFit(size :CGSize, text : String, font : NSFont) {
        var sampleFont = NSFont(descriptor: font.fontDescriptor, size: 12)!
        var sampleSize = (text as NSString).sizeWithAttributes([NSFontAttributeName : sampleFont])
        var scale = self.scaleToAspectFit(sampleSize, into: size, padding: 10)
        
    }
    
    
}