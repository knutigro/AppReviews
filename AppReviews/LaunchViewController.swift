//
//  LaunchScreenViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-28.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class LaunchViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField?
    @IBOutlet weak var checkButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel?.stringValue = NSApplication.v_versionBuild()
    }
    
    @IBAction func showButtonDidCheck(checkButton: NSButton) {
        NSUserDefaults.review_setShouldShowLaunchScreen(checkButton.state == NSOffState ? false : true)
    }
}
