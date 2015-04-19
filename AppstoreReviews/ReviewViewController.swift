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

    private var application : Application? {
        didSet {
            self.reviewArrayController?.application = self.application
            self.tableView?.reloadData()
        }
    }
    
    var applicationId : NSString? {
        didSet {
            if self.tableView != nil && oldValue != self.applicationId {
                if self.applicationId as? String != nil {
                    self.application = Application.get(self.applicationId! as String, context: self.managedObjectContext)
                }
            }
        }
    }
    
    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
}
