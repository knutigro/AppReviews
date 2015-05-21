//
//  AboutViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//
import Cocoa
import StoreKit

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField?
    @IBOutlet weak var premiumLabel: NSTextField?
    @IBOutlet weak var premiumButton: NSButton?
    @IBOutlet weak var restorePurchaseButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.versionLabel?.stringValue = NSApplication.v_versionBuild()
    }
    
    @IBAction func premiumButtonClicked(objects:AnyObject?) {
    }

    @IBAction func restoreButtonClicked(objects:AnyObject?) {
    }

    
}

