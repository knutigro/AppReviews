//
//  Application+String.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-11.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

// MARK: String Output

extension Application {
    
    func toShortString() -> String {
        var string = self.trackName
        string += "\n" + self.sellerName
        
        return string
    }
    
}
