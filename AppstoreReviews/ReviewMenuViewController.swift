//
//  ReviewMenuViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-22.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import EDStarRating

class ReviewMenuViewController: NSViewController {
    
    var managedObjectContext : NSManagedObjectContext!
    let dateFormatter = NSDateFormatter()

    @IBOutlet weak var currentVersionStarRating: EDStarRating?
    @IBOutlet weak var allVersionsStarRating: EDStarRating?
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
        
        if let starRating = self.currentVersionStarRating {
            starRating.starImage = NSImage(named: "star")
            starRating.starHighlightedImage = NSImage(named: "star-highlighted")
            starRating.maxRating = 5
            starRating.horizontalMargin = 5
            starRating.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRating.rating = 3.5
        }

        if let starRating = self.allVersionsStarRating {
            starRating.starImage = NSImage(named: "star")
            starRating.starHighlightedImage = NSImage(named: "star-highlighted")
            starRating.maxRating = 5
            starRating.horizontalMargin = 5
            starRating.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRating.rating = 3.5
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
        self.currentVersionStarRating?.rating = averageUserRatingForCurrentVersion
        
        let numberUserRatingForCurrentVersion = self.application?.userRatingCountForCurrentVersion.integerValue ?? 0

        let averageUserRating = self.application?.averageUserRating.floatValue ?? 0
        var averageUserRatingString = ""
        if averageUserRating > 0 {
            averageUserRatingString = (NSString(format: "%.1f", averageUserRating) as String)
        }
        self.allVersionsStarRating?.rating = averageUserRating

        let userRatingCount = self.application?.userRatingCount.integerValue ?? 0

        self.titleLabel.stringValue = self.application?.trackName ?? ""
        self.sellerNameLabel.stringValue =  NSLocalizedString("By: ", comment: "review.menu.by") + (self.application?.sellerName ?? "")
        self.categoryLabel.stringValue =   NSLocalizedString("Category: ", comment: "review.menu.category") + (self.application?.primaryGenreName ?? "")

        self.dateFormatter.dateStyle = .LongStyle
        self.dateFormatter.timeStyle = .NoStyle
        let releasedAt = self.application?.releaseDate != nil ? dateFormatter.stringFromDate(self.application!.releaseDate!) : ""
        self.updatedAtLabel.stringValue =  NSLocalizedString("Updated: ", comment: "review.menu.updated") + releasedAt
        self.versionLabel.stringValue =   NSLocalizedString("Version: ", comment: "review.menu.version") + (self.application?.version ?? "")
        self.sizeLabel.stringValue =   NSLocalizedString("Size: ", comment: "review.menu.size") + fileSize + " Mb"
        
        self.averageRatingCurrentLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + averageUserRatingForCurrentVersionString

        self.numberOfRatingsCurrentLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", numberUserRatingForCurrentVersion) as String)

        self.averageRatingAllLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + averageUserRatingString
        
        self.numberOfRatingsAllLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", userRatingCount) as String)
        
        self.dateFormatter.dateStyle = .LongStyle
        self.dateFormatter.timeStyle = .MediumStyle
        let updatedAt = self.application?.reviewsUpdatedAt != nil ? dateFormatter.stringFromDate(self.application!.reviewsUpdatedAt) : ""
        self.reviewsUpdatedAtLabel.stringValue = NSLocalizedString("Updated: ", comment: "review.menu.reviewUpdated") + updatedAt
    }
}