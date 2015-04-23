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

    @IBOutlet weak var averageRatingCurrentLabel: NSTextField!
    @IBOutlet weak var numberOfRatingsCurrentLabel: NSTextField!
    @IBOutlet weak var averageRatingAllLabel: NSTextField!
    @IBOutlet weak var numberOfRatingsAllLabel: NSTextField!
    @IBOutlet weak var reviewsUpdatedAtLabel: NSTextField!

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

        let number = (self.application?.averageUserRatingForCurrentVersion ?? "")
        var fileSize = NSString(format: "%.01f", self.application?.fileSizeMb ?? 0) as String
        let averageUserRatingForCurrentVersion = self.application?.averageUserRatingForCurrentVersion.floatValue ?? 0
        var averageUserRatingForCurrentVersionString = ""
        if averageUserRatingForCurrentVersion > 0 {
            averageUserRatingForCurrentVersionString = (NSString(format: "%.1f", averageUserRatingForCurrentVersion) as String)
        }
        
        let numberUserRatingForCurrentVersion = self.application?.userRatingCountForCurrentVersion.integerValue ?? 0

        let averageUserRating = self.application?.averageUserRating.floatValue ?? 0
        var averageUserRatingString = ""
        if averageUserRating > 0 {
            averageUserRatingString = (NSString(format: "%.1f", averageUserRating) as String)
        }
        
        let userRatingCount = self.application?.userRatingCount.integerValue ?? 0

        self.titleLabel.stringValue = self.application?.trackName ?? ""
        self.sellerNameLabel.stringValue =  NSLocalizedString("By: ", comment: "review.menu.by") + (self.application?.sellerName ?? "")
        self.categoryLabel.stringValue =   NSLocalizedString("Category: ", comment: "review.menu.category") + (self.application?.primaryGenreName ?? "")
        self.updatedAtLabel.stringValue =  NSLocalizedString("Updated: ", comment: "review.menu.updated") //+ (self.releaseDate?.primaryGenreName ?? "")
        self.versionLabel.stringValue =   NSLocalizedString("Version: ", comment: "review.menu.version") + (self.application?.version ?? "")
        self.sizeLabel.stringValue =   NSLocalizedString("Size: ", comment: "review.menu.size") + fileSize + " Mb"
        
        self.averageRatingCurrentLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + fileSize

        self.numberOfRatingsCurrentLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", numberUserRatingForCurrentVersion) as String)

        self.averageRatingAllLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + averageUserRatingString
        
        self.numberOfRatingsAllLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", userRatingCount) as String)
        
        self.reviewsUpdatedAtLabel.stringValue = "Updated at:" //String(self.application?.reviewsUpdatedAt)
    }
}