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
        var string = title
        string += "\n" + content
        string += "\nRating: " + String(rating.integerValue)
        string += "\n" + author
        string += "\n" + uri
        string += "\n" + application.trackName + " (Version " + version + ")"
        
        return string
    }
    
}
