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
    let reviewController = COReviewController()
    var reviews : [Review]?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = COReviewController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        COReviewController.sharedInstance.importController.importReviews("521142420", storeId: "gb")
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK : - NSTableViewDataSource

extension ReviewViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        //let numberOfRows:Int = 20
        let numberOfRows:Int = getDataArray().count
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
    {
        //        var string:String = "row " + String(row) + ", Col" + String(tableColumn.identifier)
        //        return string
        var newString: (AnyObject?) = getDataArray().objectAtIndex(row).objectForKey(tableColumn!.identifier)
        return newString;
    }
    
    func getDataArray () -> NSArray{
        var dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
            ["FirstName": "Nishant", "LastName": "Singh"],
            ["FirstName": "John", "LastName": "Doe"],
            ["FirstName": "Jane", "LastName": "Doe"],
            ["FirstName": "Mary", "LastName": "Jane"]];
        println(dataArray);
        return dataArray;
    }
}



