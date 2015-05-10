//
//  ApplicationViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-14.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//


import Cocoa
import SwiftyJSON

class ApplicationViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var applicationArrayController: ApplicationArrayController?
    var applications = [Application]()
    
    var managedObjectContext : NSManagedObjectContext!
    
    // MARK: - Init & Teardown

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = ReviewManager.managedObjectContext()
    }
    
    // MARK: - View & Navigation

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// Mark: - Actions

extension ApplicationViewController {
    
    @IBAction func removeButtonClicked(objects:AnyObject?) {
        if let applications = objects as? [Application], let rowNumber = self.tableView?.selectedRow {
            if applications.count > rowNumber && rowNumber >= 0{
                DatabaseHandler.removeApplication(applications[rowNumber].objectID)
            }
        }
    }
    
    func cellDoubleClicked(applications: [Application]?) {
        if let applications = applications, let rowNumber = self.tableView?.selectedRow {
            if applications.count > rowNumber && rowNumber >= 0{
                let application = applications[rowNumber]
                ReviewWindowController.show(application.objectID)
            }
        }
    }
}
