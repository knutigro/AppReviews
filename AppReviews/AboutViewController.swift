//
//  AboutViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//
import Cocoa
import StoreKit
import Sparkle

class AboutViewController: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel?.stringValue = NSApplication.v_versionBuild()
    }

    @IBAction func checkForUpdatesClicked(objects:AnyObject?) {
        SUUpdater.sharedUpdater().checkForUpdates(objects)
    }

    @IBAction func openGitHubClicked(objects: AnyObject?) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/knutigro/AppReviews")!)
    }

    @IBAction func openProjectPagesClicked(objects: AnyObject?) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://knutigro.github.io/apps/app-reviews/")!)
    }

}

