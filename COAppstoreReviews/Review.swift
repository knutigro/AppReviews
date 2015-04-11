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
    var reviewIdentifier : String? {
        get {
            return self["id"]["label"].string
        }
    }
    
    var isReviewEntity : Bool{
        get {
            return self.reviewIdentifier != nil
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
    @NSManaged var imVersion : String
    @NSManaged var imRating : Float
    @NSManaged var imVoteCount : Int
    @NSManaged var imVoteSum : Float
    
    required init(json : JSON, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameReview, inManagedObjectContext: context)
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
        
        self.apId = json.reviewIdentifier ?? ""
        self.author = json["author"]["name"]["label"].stringValue ?? ""
        self.uri = json["author"]["uri"]["label"].stringValue ?? ""
        self.title = json["title"]["label"].stringValue ?? ""
        self.content = json["content"]["label"].stringValue ?? ""
        self.imVersion = json["im:version"]["label"].stringValue ?? ""
        self.imRating = (json["im:rating"]["label"].stringValue as NSString).floatValue ??  0.0
        self.imVoteCount = json["im:voteCount"]["label"].stringValue.toInt() ?? 0
        self.imVoteSum = (json["im:voteSum"]["label"].stringValue as NSString).floatValue ?? 0.0
    }
    
    class func findEntryWithIdentifier(identifier : String, context: NSManagedObjectContext) -> Review? {
        
        let fetchRequest = NSFetchRequest(entityName: kEntityNameReview)
        fetchRequest.predicate = NSPredicate(format: "apId = %@", identifier)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        if let lastObject = result?.last as? Review{
            return lastObject
        } else {
            return nil
        }
    }
}
