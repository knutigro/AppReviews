//
//  ApplicationSearchViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import SwiftyJSON

class SearchViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView?
    
    var items = [JSON]()
    
    var managedObjectContext : NSManagedObjectContext!
    let reviewController = ReviewController()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = ReviewController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ReviewController.sharedInstance.importController.importReviews("521142420", storeId: "gb")
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
        cell.textField?.stringValue = application["trackName"].stringValue
        cell.authorTextField?.stringValue = application["sellerName"].stringValue
        
        let urlString = application["artworkUrl60"].stringValue
        
        if let url = NSURL(string: urlString) {
            cell.imageView? .setImageWithUrl(url, placeHolderImage: nil)
        }

        return cell;
    }
}

