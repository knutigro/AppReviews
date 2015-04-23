//
//  ApplicationWindow.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-21.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import SwiftyJSON

class ApplicationWindowController : NSWindowController {
    @IBOutlet weak var searchField: NSSearchField?
    var searchWindowController : NSWindowController?
}

// MARK: - SearchField

extension ApplicationWindowController  {
    override func controlTextDidEndEditing(notification : NSNotification) {
        if let textField = notification.object as? NSTextField {
            if !textField.stringValue.isEmpty {
                self.openSearchResultController()
                self.searchApp(textField.stringValue)
            }
        }
    }
}

// MARK: - Search Apps

extension ApplicationWindowController  {
    
    func searchApp(name: String) {
        let appFetcher = AppFetcher()
        
        appFetcher.fetchApplications(name) { [weak self]
            (success: Bool, applications: JSON?, error : NSError?)
            in
            
            let blockSuccess = success as Bool
            let blockError = error
            
            if blockError != nil {
                println("error: " + blockError!.localizedDescription)
            }
            
            if let applications = applications?.arrayValue {
                if let strongSelf = self {
                    strongSelf.openSearchResult(applications)
                }
            }
        }
    }
    
    func openSearchResult(items: [JSON]) {
        
        if self.searchWindowController == nil {
            self.openSearchResultController()
        }
        if let searchViewController = self.searchWindowController?.window?.contentViewController as? SearchViewController {
            searchViewController.items = items
            searchViewController.tableView?.reloadData()
            searchViewController.state = .Idle
        }
    }
    
    func openSearchResultController() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        self.searchWindowController = storyboard.instantiateControllerWithIdentifier("SearchResultWindowController") as? NSWindowController
        var window = self.searchWindowController?.window
        
        if let searchViewController = window?.contentViewController as? SearchViewController {
            searchViewController.delegate = self
            searchViewController.state = .Loading
        }
        
        self.window?.beginSheet(window!) {
            (returnCode : NSModalResponse)
            in
            self.searchWindowController = nil
        }
    }
}

// Mark: - SearchViewControllerDelegate

extension ApplicationWindowController : SearchViewControllerDelegate {
    func searchViewController(searchViewController : SearchViewController, didSelectApplication application: JSON) {
        self.searchField?.stringValue = ""
        DBController.sharedInstance.appstoreReviewController.saveApplication(application)
        if let searchWindow = self.searchWindowController?.window {
            self.window?.endSheet(searchWindow)
        }
    }
    
    func searchViewControllerDidCancel(searchViewController : SearchViewController) {
        self.searchField?.stringValue = ""
        if let searchWindow = self.searchWindowController?.window {
            self.window?.endSheet(searchWindow)
        }
    }
}


