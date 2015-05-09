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
        
        let canAddAplication = ReviewManager.appUpdater().canAddApplication
        if canAddAplication.result {
            if let textField = notification.object as? NSTextField {
                if !textField.stringValue.isEmpty {
                    self.openSearchResultController()
                    self.searchApp(textField.stringValue)
                }
            }
        } else {
            var alert = NSAlert()
            alert.messageText = canAddAplication.description
            alert.addButtonWithTitle(NSLocalizedString("Get Premium", comment: "alert.premium.open"))
            alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: "alert.premium.cancel"))
            alert.beginSheetModalForWindow(self.window!, completionHandler: { (response: NSModalResponse) -> Void in
                if response == 1000 {
                    let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                    let windowController = appdelegate.aboutWindowController
                    windowController.showWindow(self)
                    NSApp.activateIgnoringOtherApps(true)
                }
            })
        }
    }
}

// MARK: - Search Apps

extension ApplicationWindowController  {
    
    func searchApp(name: String) {
        
        ItunesService.fetchApplications(name) { [weak self]
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

        DatabaseHandler.saveApplication(application)

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
