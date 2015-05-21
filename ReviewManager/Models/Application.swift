//
//  Application.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

let kEntityNameApplication = "Application"

@objc(Application)

class Application : NSManagedObject {
    
    @NSManaged var artworkUrl60 : String
    @NSManaged var artworkUrl512 : String
    @NSManaged var artistViewUrl : String
    @NSManaged var fileSizeBytes : String
    @NSManaged var sellerUrl : String
    @NSManaged var averageUserRatingForCurrentVersion : NSNumber
    @NSManaged var userRatingCountForCurrentVersion : NSNumber
    @NSManaged var trackViewUrl : String
    @NSManaged var version : String
    @NSManaged var releaseDate : NSDate?
    @NSManaged var sellerName : String
    @NSManaged var artistId : String
    @NSManaged var artistName : String
    @NSManaged var itunesDescription : String
    @NSManaged var bundleId : String
    @NSManaged var trackId : String
    @NSManaged var trackName : String
    @NSManaged var primaryGenreName : String
    @NSManaged var primaryGenreId : String
    @NSManaged var releaseNotes : String
    @NSManaged var minimumOsVersion : String
    @NSManaged var averageUserRating : NSNumber
    @NSManaged var userRatingCount : NSNumber
    @NSManaged var createdAt : NSDate
    @NSManaged var updatedAt : NSDate
    @NSManaged var reviews : NSSet
    @NSManaged var settings : ApplicationSettings

    var fileSizeMb : Float {
        get {
            var fileSize = self.fileSizeBytes.toInt() ?? 0
            var mb = Float(fileSize) / 1000000
            return max(mb, 0.0)
        }
    }

    // MARK: - Init & teardown

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameApplication, inManagedObjectContext: context)
        self.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
    }
    
    // MARK: - Class functions for create and insert and search
    
    class func getWithIds(ids : Set<NSManagedObjectID>, context: NSManagedObjectContext) -> [Application]? {
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        
        fetchRequest.predicate = NSPredicate(format: "self in %@", Array(ids))
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        return result as? [Application]
    }

    class func getWithAppId(identifier : String, context: NSManagedObjectContext) -> Application? {

        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        fetchRequest.predicate = NSPredicate(format: "trackId = %@", identifier)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        return result?.last as? Application
    }
    
    class func new(identifier : String, context: NSManagedObjectContext) -> Application {
        let application = Application(insertIntoManagedObjectContext: context)
        application.trackId = identifier;
        application.settings = ApplicationSettings.new(application, context: context)
        application.createdAt = NSDate()
        application.updatedAt = NSDate()
        
        return application
    }

    class func getOrCreateNew(identifier : String, context: NSManagedObjectContext) -> Application {
        if let application = Application.getWithAppId(identifier, context: context) {
            return application
        } else {
            return Application.new(identifier, context: context)
        }
    }
    
    class func insertNewObjectIntoContext(context: NSManagedObjectContext) -> Application {
        return NSEntityDescription.insertNewObjectForEntityForName(kEntityNameApplication, inManagedObjectContext: context) as! Application
    }
}

// MARK: - Application extension of JSON

extension Application {
    
    func updateWithJSON(json : JSON) {
        
        self.artworkUrl60 = json.artworkUrl60 ?? ""
        self.artworkUrl512 = json.artworkUrl512 ?? ""
        self.artistViewUrl = json.artistViewUrl ?? ""
        self.fileSizeBytes = json.fileSizeBytes ?? ""
        self.sellerUrl = json.sellerUrl ?? ""
        self.version = json.version ?? ""
        self.averageUserRatingForCurrentVersion = json.averageUserRatingForCurrentVersion
        self.userRatingCountForCurrentVersion = json.userRatingCountForCurrentVersion
        self.trackViewUrl = json.trackViewUrl ?? ""
        self.version = json.version ?? ""
        self.releaseDate = json.releaseDate
        self.sellerName = json.sellerName ?? ""
        self.artistId = json.artistId ?? ""
        self.artistName = json.artistName ?? ""
        self.itunesDescription = json.itunesDescription ?? ""
        self.bundleId = json.bundleId ?? ""
        self.trackId = json.trackId ?? ""
        self.trackName = json.trackName ?? ""
        self.primaryGenreName = json.primaryGenreName ?? ""
        self.primaryGenreId = json.primaryGenreId ?? ""
        self.releaseNotes = json.releaseNotes ?? ""
        self.minimumOsVersion = json.minimumOsVersion ?? ""
        self.averageUserRating = json.averageUserRating
        self.userRatingCount = json.userRatingCount

    }
}

// MARK: - JSON extension of Application

extension JSON {
    
    var artworkUrl60 : String? { get { return self["artworkUrl60"].string  } }
    var artworkUrl512 : String? { get { return self["artworkUrl512"].string  } }
    var artistViewUrl : String? { get { return self["artistViewUrl"].string  } }
    var fileSizeBytes : String? { get { return self["fileSizeBytes"].string  } }
    var sellerUrl : String? { get { return self["sellerUrl"].string  } }
    var averageUserRatingForCurrentVersion : NSNumber { get { return NSNumber(float:(self["averageUserRatingForCurrentVersion"].stringValue as NSString).floatValue) } }
    var userRatingCountForCurrentVersion : NSNumber { get { return NSNumber(integer: self["userRatingCountForCurrentVersion"].stringValue.toInt() ?? 0) } }
    var trackViewUrl : String? { get { return self["trackViewUrl"].string  } }
    var version : String? { get { return self["version"].string  } }
    var releaseDate : NSDate? {
        get {
            var date : NSDate? = nil
            if let dateString = self["releaseDate"].string {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SS:SS'"
                date = dateFormatter.dateFromString(dateString)
            }
            return date
        }
    }
    var sellerName : String? { get { return self["sellerName"].string  } }
    var artistId : String? { get { return self["artistId"].string  } }
    var artistName : String? { get { return self["artistName"].string  } }
    var itunesDescription : String? { get { return self["itunesDescription"].string  } }
    var bundleId : String? { get { return self["bundleId"].string  } }
    var trackId : String? { get { return self["trackId"].int != nil ? String(self["trackId"].int!) : nil } }
    var trackName : String? { get { return self["trackName"].string  } }
    var primaryGenreName : String? { get { return self["primaryGenreName"].string  } }
    var primaryGenreId : String? { get { return self["primaryGenreId"].string  } }
    var releaseNotes : String? { get { return self["releaseNotes"].string  } }
    var minimumOsVersion : String? { get { return self["minimumOsVersion"].string  } }
    var averageUserRating : NSNumber { get { return NSNumber(float:(self["averageUserRating"].stringValue as NSString).floatValue) } }
    var userRatingCount : NSNumber { get { return NSNumber(integer: self["userRatingCount"].stringValue.toInt() ?? 0) } }
    
    var isApplicationEntity : Bool{
        get {
            return self.trackId != nil
        }
    }
}