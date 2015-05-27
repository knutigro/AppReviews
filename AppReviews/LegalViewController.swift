//
//  LegalViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-27.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class LegalViewController: NSViewController {
    
    var textView: NSTextView? {
        let scrollView = view as? NSScrollView
        return scrollView?.contentView.documentView as? NSTextView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rtfFilePath = NSBundle.mainBundle().pathForResource("3dPartyLicenses", ofType: "rtf")
        textView?.readRTFDFromFile(rtfFilePath!)
    }
}
