//
//  ReviewMenuViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-22.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewMenuViewController: NSViewController {
    
    var managedObjectContext : NSManagedObjectContext!
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var sellerNameLabel: NSTextField!
    @IBOutlet weak var categoryLabel: NSTextField!
    @IBOutlet weak var updatedAtLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var sizeLabel: NSTextField!

    var application : Application? {
        didSet {
            self.updateApplicationInfo()
        }
    }

    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.application != nil {
            self.updateApplicationInfo()
        }
    }
    
    // MARK: - UI
    
    func updateApplicationInfo() {
        
        var fileSize = NSString(format: "%.01f", self.application?.fileSizeMb ?? 0) as String
        
        self.titleLabel.stringValue = self.application?.trackName ?? ""
        self.sellerNameLabel.stringValue =  NSLocalizedString("By: ", comment: "review.menu.by") + (self.application?.sellerName ?? "")
        self.categoryLabel.stringValue =   NSLocalizedString("Category: ", comment: "review.menu.category") + (self.application?.primaryGenreName ?? "")
        self.updatedAtLabel.stringValue =  NSLocalizedString("Updated: ", comment: "review.menu.updated") //+ (self.releaseDate?.primaryGenreName ?? "")
        self.versionLabel.stringValue =   NSLocalizedString("Version: ", comment: "review.menu.version") + (self.application?.version ?? "")
        self.sizeLabel.stringValue =   NSLocalizedString("Size: ", comment: "review.menu.size") + fileSize + " Mb"
    }
}