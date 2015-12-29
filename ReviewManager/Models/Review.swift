//
//  Review.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

let kEntityNameReview = "Review"

@objc(Review)
class Review: NSManagedObject {
    
    @NSManaged var apId: String
    @NSManaged var author: String
    @NSManaged var uri: String
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var version: String
    @NSManaged var rating: NSNumber
    @NSManaged var voteCount: NSNumber
    @NSManaged var voteSum: NSNumber
    @NSManaged var country: String
    @NSManaged var application: Application
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

    // MARK: - init & teardown

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameReview, inManagedObjectContext: context)
        self.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
    }
    
    // MARK: - Class functions for create and insert
    
    class func getWithId(id: NSManagedObjectID, context: NSManagedObjectContext) -> Review? {
        var result: NSManagedObject?
        do {
            result = try context.existingObjectWithID(id)
        } catch let error as NSError {
            print(error)
        }
        
        return result as? Review
    }

    class func get(apId: String, context: NSManagedObjectContext) -> Review? {
        let fetchRequest = NSFetchRequest(entityName: kEntityNameReview)
        fetchRequest.predicate = NSPredicate(format: "apId = %@", apId)
        var result: [AnyObject]?
        do {
            result = try context.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print(error)
        }
        
        return result?.last as? Review
    }

    class func new(apId: String, context: NSManagedObjectContext) -> Review {
        let review = Review(insertIntoManagedObjectContext: context)
        review.apId = apId;
        review.createdAt = NSDate()
        review.updatedAt = NSDate()
        return review
    }
    
    class func getOrCreateNew(apId: String, context: NSManagedObjectContext) -> Review {
        if let review = Review.get(apId, context: context) {
            return review
        } else {
            return Review.new(apId, context: context)
        }
    }
    
    class func insertNewObjectIntoContext(context: NSManagedObjectContext) -> Review {
        return NSEntityDescription.insertNewObjectForEntityForName(kEntityNameReview, inManagedObjectContext: context) as! Review
    }
}

// MARK: - Review extension of JSON

extension Review {
    
    func updateWithJSON(json: JSON) {
        
        apId = json.reviewApID ?? ""
        author = json.reviewAuthor ?? ""
        uri = json.reviewUri ?? ""
        title = json.reviewTitle ?? ""
        content = json.reviewContent ?? ""
        version = json.reviewVersion ?? ""
        rating = json.reviewRating
        voteCount = json.reviewVoteCount
        voteSum = json.reviewVoteSum
    }
}

// MARK: - JSON extension of Review

extension JSON {
    var reviewApID: String? { return self["id"]["label"].string }
    var reviewContent: String? { return self["content"]["label"].string }
    var reviewAuthor: String? { return self["author"]["name"]["label"].string }
    var reviewUri: String? { return self["author"]["uri"]["label"].string }
    var reviewTitle: String? { return self["title"]["label"].string }
    var reviewVersion: String? { return self["im:version"]["label"].string }
    var reviewRating: NSNumber { return NSNumber(integer: Int(self["im:rating"]["label"].stringValue) ?? 0) }
    var reviewVoteCount: NSNumber { return NSNumber(integer: Int(self["im:voteCount"]["label"].stringValue) ?? 0)  }
    var reviewVoteSum: NSNumber { return NSNumber(float:(self["im:voteSum"]["label"].stringValue as NSString).floatValue) }
    
    var isReviewEntity: Bool { return (self.reviewContent != nil || self.reviewRating.integerValue > 0)    }
}
