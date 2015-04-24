//
//  ViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class ReviewViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet var reviewArrayController: ReviewArrayController?
    
    var managedObjectContext : NSManagedObjectContext!
    private let dbController = DBController()

    var application : Application? {
        didSet {
            self.reviewArrayController?.application = self.application
            self.tableView?.reloadData()
        }
    }
    
    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
}

// MARK: NSTableViewDelegate

extension ReviewViewController : NSTableViewDelegate {

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        let review = self.reviewArrayController?.arrangedObjects[row] as? Review
        var height = review?.content.size(tableView.frame.size.width - 85, font: NSFont.systemFontOfSize(13)).height ?? 0
        
        return height + 80
    }
}
    
