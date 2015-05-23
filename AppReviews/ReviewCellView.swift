//
//  ReviewCellView.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-12.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import EDStarRating

class ReviewCellView: NSTableCellView {
    
    @IBOutlet weak var starRating: EDStarRating?
    private var kvoContext = 0
    
    deinit {
        self.removeObserver(self, forKeyPath: "objectValue", context: &kvoContext)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.addObserver(self, forKeyPath: "objectValue", options: .New, context: &kvoContext)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let starRating = self.starRating {
            starRating.starImage = NSImage(named: "star")
            starRating.starHighlightedImage = NSImage(named: "star-highlighted")
            starRating.maxRating = 5
            starRating.delegate = self
            starRating.horizontalMargin = 5
            starRating.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRating.rating = 3.5
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            if let starRating = self.starRating, objectValue = self.objectValue as? NSManagedObject {
                starRating.bind("rating", toObject: objectValue, withKeyPath: "rating", options: nil)
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}

// MARK: EDStarRatingProtocol

extension ReviewCellView: EDStarRatingProtocol {
    
}