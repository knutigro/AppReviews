//
//  Application.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    var applicationIdentifier : String? {
        get {
            return self["id"]["attributes"]["im:id"].string
        }
    }

    var isApplicationEntity : Bool{
        get {
            return self.applicationIdentifier != nil
        }
    }
}

let kEntityNameApplication = "Application"

@objc(Application)
class Application : NSManagedObject, ItunesEntryProtocol {
    
    @NSManaged var apId : String
    @NSManaged var bundleId : String
    @NSManaged var name : String
    @NSManaged var contentType : String
    @NSManaged var categoryId : String
    @NSManaged var category : String
    @NSManaged var releaseDate : NSDate
    @NSManaged var title : String
    @NSManaged var artist : String
    @NSManaged var image : String
    
    required init(json: JSON, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameApplication, inManagedObjectContext: context)
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
        
        self.apId = json.applicationIdentifier ?? ""
        self.bundleId = json["id"]["attributes"]["im:bundleId"].stringValue ?? ""
        self.name = json["im:name"]["label"].stringValue ?? ""
        self.contentType = json["im:contentType"]["attributes"]["term"].stringValue ?? ""
        self.categoryId = json["category"]["attributes"]["im:id"].stringValue ?? ""
        self.category = json["category"]["attributes"]["term"].stringValue ?? ""
        self.title = json["title"]["label"].stringValue ?? ""
        self.artist = json["im:artist"]["label"].stringValue ?? ""
        self.image = json["im:image"][0]["label"].stringValue ?? ""
        
        if let dateString = json["im:releaseDate"]["label"].string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:SS'"
            if let date = dateFormatter.dateFromString(dateString) {
                self.releaseDate = date
            }
        }
    }

    class func findEntryWithIdentifier(identifier : String, context: NSManagedObjectContext) -> Application? {
        
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        fetchRequest.predicate = NSPredicate(format: "apId = %@", identifier)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        if let lastObject = result?.last as? Application{
            return lastObject
        } else {
            return nil
        }
    }

    
}
