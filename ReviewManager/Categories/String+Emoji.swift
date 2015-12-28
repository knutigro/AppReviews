//
//  String+Emoji.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-12.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

// Emoji extension

extension Int {
    
    func toEmojiStars() -> String {
        var starArray = [String]()
        for _ in 1 ... self {
            starArray.append("⭐️")
        }
        
        return starArray.joinWithSeparator("")
    }


}
