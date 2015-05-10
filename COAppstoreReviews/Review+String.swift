//
//  Application+String.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

// MARK: String Output

extension Review {
    
    func toString() -> String {
        var string = self.title
        string += "\n" + self.content
        string += "\nRating: " + String(self.rating.integerValue)
        string += "\n" + self.author
        string += "\n" + self.uri
        string += "\n" + self.application.trackName + " (Version " + self.version + ")"
        
        return string
    }
    
}
