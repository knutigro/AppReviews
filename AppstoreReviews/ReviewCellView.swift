//
//  ReviewCellView.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-12.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewCellView : NSTableCellView {
    
    @IBOutlet weak var titleTextField: NSTextField?
    @IBOutlet weak var versionTextField: NSTextField?
    @IBOutlet weak var authorTextField: NSTextField?
    @IBOutlet weak var ratingsView: NSTextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
}