//
//  ApplicationCellView.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

let kApplicationCellIdentifier = "applicationCell"

class ApplicationCellView: NSTableCellView {
    
    @IBOutlet weak var authorTextField: NSTextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

