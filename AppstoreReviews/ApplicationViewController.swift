//
//  ApplicationViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-14.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//


import Cocoa
import SwiftyJSON

let kOpenApplicationSearchSegue = "openApplicationSearchSegue"

class ApplicationViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView?
    @IBOutlet var applicationArrayController: ApplicationArrayController?
    var applications = [Application]()
    
    var managedObjectContext : NSManagedObjectContext!
    
    // MARK: - Init & Teardown

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
    
    // MARK: - View & Navigation

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kOpenApplicationSearchSegue {
            if let searchViewController = segue.destinationController as? SearchViewController {
                searchViewController.delegate = self
            }
        }
    }
}

// Mark: - Actions

extension ApplicationViewController {
    
    @IBAction func removeButtonClicked(objects:AnyObject?) {
        if let applications = objects as? [Application], let rowNumber = self.tableView?.selectedRow {
            if applications.count > rowNumber && rowNumber >= 0{
                let application = applications[rowNumber]
                DBController.sharedInstance.reviewController.removeApplication(application)
            }
        }
    }
    
    func cellDoubleClicked(applications: [Application]?) {
        if let applications = applications, let rowNumber = self.tableView?.selectedRow {
            if applications.count > rowNumber && rowNumber >= 0{
                let application = applications[rowNumber]
                ReviewWindowController.show(application.trackId)
            }
        }
    }
}

// Mark: - SearchViewControllerDelegate

extension ApplicationViewController : SearchViewControllerDelegate {
    func searchViewController(searchViewController : SearchViewController, didSelectApplication application: JSON) {
        DBController.sharedInstance.reviewController.updateApplication(application)
    }
}