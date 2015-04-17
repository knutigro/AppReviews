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
    private let dbController = DBController()
    private var application : Application?
    var applicationId : NSString? {
        didSet {
            if self.tableView != nil && oldValue != self.applicationId {
                self.updateReviews()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateReviews()
    }
    
    private func updateReviews() {
        if self.applicationId as? String != nil {
            self.application = Application.findApplication(self.applicationId! as String, context: self.managedObjectContext)
            
            if let application = self.application {
                self.reviewArrayController?.filterPredicate = NSPredicate(format: "application = %@", application)
                DBController.sharedInstance.reviewController.updateReviews(application, storeId: nil)
            }
            
            self.tableView?.reloadData()
        }
    }
}

