//
//  ViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class ReviewViewController: NSViewController {

    @IBOutlet var tableView: NSTableView?
    @IBOutlet var reviewArrayController: ReviewArrayController?
    
    var managedObjectContext : NSManagedObjectContext!
    let reviewController = ReviewController()
    var application : Application?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = ReviewController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let application = self.application {
            self.reviewArrayController?.filterPredicate = NSPredicate(format: "application = %@", application)
            ReviewController.sharedInstance.dataBaseController.updateReviews(application, storeId: nil)
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

