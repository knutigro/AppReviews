//
//  Review.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    var reviewApID : String? { get { return self["id"]["label"].string  } }
    var reviewContent : String? { get { return self["content"]["label"].string  } }
    var reviewAuthor : String? { get { return self["author"]["name"]["label"].string  } }
    var reviewUri : String? { get { return self["author"]["uri"]["label"].string  } }
    var reviewTitle : String? { get { return self["title"]["label"].string  } }
    var reviewVersion : String? { get { return self["im:version"]["label"].string  } }
    var reviewRating : NSNumber { get { return NSNumber(integer: self["im:rating"]["label"].stringValue.toInt() ?? 0) } }
    var reviewVoteCount : NSNumber { get { return NSNumber(integer: self["im:voteCount"]["label"].stringValue.toInt() ?? 0) } }
    var reviewVoteSum : NSNumber { get { return NSNumber(float:(self["im:voteSum"]["label"].stringValue as NSString).floatValue) } }

    var isReviewEntity : Bool {
        get {
            return (self.reviewContent != nil || self.reviewRating > 0)
        }
    }
}

let kEntityNameReview = "Review"

@objc(Review)
class Review : NSManagedObject, ItunesEntryProtocol{
    
    @NSManaged var apId : String
    @NSManaged var author : String
    @NSManaged var uri : String
    @NSManaged var title : String
    @NSManaged var content : String
    @NSManaged var version : String
    @NSManaged var rating : NSNumber
    @NSManaged var voteCount : NSNumber
    @NSManaged var voteSum : NSNumber
    @NSManaged var country : String
    @NSManaged var application : Application
    @NSManaged var createdAt : NSDate
    @NSManaged var updatedAt : NSDate

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameReview, inManagedObjectContext: context)
        self.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
    }
    
    class func findOrCreateNewReview(apId : String, context: NSManagedObjectContext) -> Review {
        
        let fetchRequest = NSFetchRequest(entityName: kEntityNameReview)
        fetchRequest.predicate = NSPredicate(format: "apId = %@", apId)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        if let lastObject = result?.last as? Review{
            return lastObject
        } else {
            let review = Review(insertIntoManagedObjectContext: context)
            review.createdAt = NSDate()
            review.updatedAt = NSDate()
            return review
        }
    }
    
    class func insertNewObjectIntoContext(context: NSManagedObjectContext) -> Review {
        return NSEntityDescription.insertNewObjectForEntityForName(kEntityNameReview, inManagedObjectContext: context) as! Review
    }
}

// MARK: JSON

extension Review {
    
    func updateWithJSON(json : JSON) {
        
        self.apId = json.reviewApID ?? ""
        self.author = json.reviewAuthor ?? ""
        self.uri = json.reviewUri ?? ""
        self.title = json.reviewTitle ?? ""
        self.content = json.reviewContent ?? ""
        self.version = json.reviewVersion ?? ""
        self.rating = json.reviewRating
        self.voteCount = json.reviewVoteCount
        self.voteSum = json.reviewVoteSum
    }
}
