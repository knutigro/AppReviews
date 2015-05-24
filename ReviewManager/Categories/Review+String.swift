//
//  Application+String.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

// MARK: String Output

extension Review {
    
    func toString() -> String {
        var string = self.rating.integerValue.toEmojiStars()
        string += "\n" + title
        string += "\n" + content
        string += "\n" + author
        string += "\n" + uri
        string += "\n" + application.trackName + " (" + version + ")"
        
        return string
    }
    
}
