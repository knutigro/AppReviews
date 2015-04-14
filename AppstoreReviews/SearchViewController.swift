//
//  ApplicationSearchViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import SwiftyJSON

protocol SearchViewControllerDelegate {
    func searchViewController(searchViewController : SearchViewController, didSelectApplication application: JSON)
}

class SearchViewController: NSViewController {
    
    @IBOutlet var searchField: NSSearchField?
    @IBOutlet var tableView: NSTableView?
    var items = [JSON]()
    var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.target = self
        self.tableView?.doubleAction = Selector("doubleClickedCell:")
        
        self.searchField?.becomeFirstResponder()
        
        println("Search \(ReviewController.sharedInstance.persistentStack.managedObjectContext)")
    }
    
    func doubleClickedCell(object : AnyObject) {
        if let rowNumber = self.tableView?.selectedRow {
            let application = self.items[rowNumber]
            delegate?.searchViewController(self, didSelectApplication: application)
            self.dismissController(self)
        }
    }
}

// MARK: SearchField

extension SearchViewController  {
    override func controlTextDidEndEditing(notification : NSNotification) {
        if let textField = notification.object as? NSTextField {
            if !textField.stringValue.isEmpty {
                self.searchApp(textField.stringValue)
            }
        }
    }
}

// MARK: Search Apps

extension SearchViewController  {
    
    func searchApp(name: String) {
        // [unowned self]
        
        let appFetcher = AppFetcher()
        
        appFetcher.fetchApplications(name) {
            (success: Bool, applications: JSON?, error : NSError?)
            in
            
            let blockSuccess = success as Bool
            let blockError = error
            
            if blockError != nil {
                println("error: " + blockError!.localizedDescription)
            }
            
            if let applications = applications?.arrayValue {
                self.items = applications
                self.tableView?.reloadData()
            }
        }
    }
}

// MARK: NSTableViewDataSource

extension SearchViewController : NSTableViewDataSource {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = tableView.makeViewWithIdentifier(kApplicationCellIdentifier, owner: self) as! ApplicationCellView
        let application = self.items[row]
        cell.textField?.stringValue = application.trackName ?? ""
        cell.authorTextField?.stringValue = application.sellerName ?? ""
        
        println("trackId \(application.trackId)")
        
        if let urlString = application.artworkUrl60 {
            if let url = NSURL(string: urlString) {
                cell.imageView?.setImageWithUrl(url, placeHolderImage: nil)
            }
        }

        return cell;
    }
}

