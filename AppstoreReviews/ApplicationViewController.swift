//
//  ApplicationViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-14.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//


import Cocoa
import SwiftyJSON

let kOpenReviewListSegue = "openReviewListSegue"
let kOpenApplicationSearchSegue = "openApplicationSearchSegue"

class ApplicationViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView?
    @IBOutlet var applicationArrayController: ApplicationArrayController?
    var applications = [Application]()
    
    var managedObjectContext : NSManagedObjectContext!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = ReviewController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kOpenApplicationSearchSegue {
            if let searchViewController = segue.destinationController as? SearchViewController {
                searchViewController.delegate = self
            }
        } else if segue.identifier == kOpenReviewListSegue {
            if let reviewViewController = segue.destinationController as? ReviewViewController,
                let applications = sender as? [Application] {
                reviewViewController.application = applications.first
            }
        }
    }
}

// Mark: Actions

extension ApplicationViewController {
    
    @IBAction func removeButtonClicked(objects:AnyObject?) {
        if let applications = objects as? [Application], let rowNumber = self.tableView?.selectedRow{
            if applications.count > rowNumber && rowNumber > 0{
                let application = applications[rowNumber]
                ReviewController.sharedInstance.dataBaseController.removeApplication(application)
            }
        }
    }
    
    @IBAction func cellDoubleClicked(application:Application?) {
        if let application = application {
            self.performSegueWithIdentifier(kOpenReviewListSegue, sender: application)
        }
    }
}

// Mark: SearchViewControllerDelegate

extension ApplicationViewController : SearchViewControllerDelegate {
    func searchViewController(searchViewController : SearchViewController, didSelectApplication application: JSON) {
        ReviewController.sharedInstance.dataBaseController.addApplication(application)
    }
}