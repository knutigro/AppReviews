//
//  ReviewMenuViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-22.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import EDStarRating

enum UpdateLabelState {
    case LastUpdate
    case NextUpdate
}

class ReviewMenuViewController: NSViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    let dateFormatter = NSDateFormatter()
    var updateLabelState = UpdateLabelState.LastUpdate {
        didSet {
            dateFormatter.dateStyle = .LongStyle
            dateFormatter.timeStyle = .MediumStyle
            switch updateLabelState {
            case .LastUpdate:
                let updatedAt = application?.settings.reviewsUpdatedAt != nil ? dateFormatter.stringFromDate(application!.settings.reviewsUpdatedAt!): ""
                reviewsUpdatedAtLabel.stringValue = NSLocalizedString("Updated: ", comment: "review.menu.reviewUpdated") + updatedAt
            case .NextUpdate:
                let nextUpdate = application?.settings.nextUpdateAt != nil ? dateFormatter.stringFromDate(application!.settings.nextUpdateAt!): ""
                reviewsUpdatedAtLabel.stringValue = NSLocalizedString("Next: ", comment: "review.menu.reviewNextUpdate") + nextUpdate
            }
        }
    }

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

    @IBOutlet weak var localTotalRatingsLabel: NSTextField!

    var pieChartController: ReviewPieChartController?

    var application: Application? {
        didSet {
            updateApplicationInfo()
        }
    }

    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        managedObjectContext = ReviewManager.managedObjectContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force Updated label to position on top of other views
        reviewsUpdatedAtLabel.superview?.wantsLayer = true;
        reviewsUpdatedAtLabel.superview?.layer?.zPosition = 1000;
        
        if application != nil {
            updateApplicationInfo()
        }
        
        if let starRating = currentVersionStarRating {
            starRating.starImage = NSImage(named: "star")
            starRating.starHighlightedImage = NSImage(named: "star-highlighted")
            starRating.maxRating = 5
            starRating.horizontalMargin = 5
            starRating.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRating.rating = 3.5
        }

        if let starRating = allVersionsStarRating {
            starRating.starImage = NSImage(named: "star")
            starRating.starHighlightedImage = NSImage(named: "star-highlighted")
            starRating.maxRating = 5
            starRating.horizontalMargin = 5
            starRating.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRating.rating = 3.5
        }
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.updateApplicationInfo()
            })
        }
        
        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.updateApplicationInfo()
            })
        }
    }
    
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationController as? ReviewPieChartController {
            pieChartController = controller
        }
    }
    // MARK: - UI
    
    func updateApplicationInfo() {

        let number = (application?.averageUserRatingForCurrentVersion ?? "")
        var fileSize = NSString(format: "%.01f", application?.fileSizeMb ?? 0) as String
        let averageUserRatingForCurrentVersion = application?.averageUserRatingForCurrentVersion.floatValue ?? 0
        var averageUserRatingForCurrentVersionString = ""
        if averageUserRatingForCurrentVersion > 0 {
            averageUserRatingForCurrentVersionString = (NSString(format: "%.1f", averageUserRatingForCurrentVersion) as String)
        }
        currentVersionStarRating?.rating = averageUserRatingForCurrentVersion
        
        let numberUserRatingForCurrentVersion = application?.userRatingCountForCurrentVersion.integerValue ?? 0

        let averageUserRating = application?.averageUserRating.floatValue ?? 0
        var averageUserRatingString = ""
        if averageUserRating > 0 {
            averageUserRatingString = (NSString(format: "%.1f", averageUserRating) as String)
        }
        allVersionsStarRating?.rating = averageUserRating

        let userRatingCount = application?.userRatingCount.integerValue ?? 0

        titleLabel.stringValue = application?.trackName ?? ""
        sellerNameLabel.stringValue =  NSLocalizedString("By: ", comment: "review.menu.by") + (application?.sellerName ?? "")
        categoryLabel.stringValue =   NSLocalizedString("Category: ", comment: "review.menu.category") + (application?.primaryGenreName ?? "")

        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .NoStyle
        let releasedAt = application?.releaseDate != nil ? dateFormatter.stringFromDate(application!.releaseDate!): ""
        updatedAtLabel.stringValue =  NSLocalizedString("Updated: ", comment: "review.menu.updated") + releasedAt
        versionLabel.stringValue =   NSLocalizedString("Version: ", comment: "review.menu.version") + (application?.version ?? "")
        sizeLabel.stringValue =   NSLocalizedString("Size: ", comment: "review.menu.size") + fileSize + " Mb"
        
        averageRatingCurrentLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + averageUserRatingForCurrentVersionString

        numberOfRatingsCurrentLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", numberUserRatingForCurrentVersion) as String)

        averageRatingAllLabel.stringValue =   NSLocalizedString("Average rating: ", comment: "review.menu.currentAverageRating") + averageUserRatingString
        
        numberOfRatingsAllLabel.stringValue =   NSLocalizedString("Number of ratings: ", comment: "review.menu.currentAverageRating") + (NSString(format: "%i", userRatingCount) as String)
        
        updateLabelState = .LastUpdate
        
        if let application = application {
            let reviews = DatabaseHandler.numberOfReviewsForApplication(application.objectID, rating: nil, context: ReviewManager.managedObjectContext())
            pieChartController?.slices = [Float(reviews.0), Float(reviews.1), Float(reviews.2), Float(reviews.3), Float(reviews.4)]
            pieChartController?.pieChart?.reloadData()
            let total = reviews.0 + reviews.1 + reviews.2 + reviews.3 + reviews.4
            localTotalRatingsLabel.stringValue = NSLocalizedString("Total: ", comment: "review.menu.localRatingCount") + (NSString(format: "%i", total) as String)
        }

        
    }
    
    @IBAction func toogleUpdateLabel(objects:AnyObject?) {
        if (updateLabelState == .LastUpdate) {
            updateLabelState = .NextUpdate
        } else {
            updateLabelState = .LastUpdate
        }
    }
}

