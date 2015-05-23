//
//  ApplicationSettings.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-25.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

let kEntityNameApplicationSettings = "ApplicationSettings"

@objc(ApplicationSettings)

class ApplicationSettings: NSManagedObject {
    
    @NSManaged var automaticUpdate: Bool
    @NSManaged var newReviews: NSNumber
    @NSManaged var reviewsUpdatedAt: NSDate?
    @NSManaged var nextUpdateAt: NSDate?
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var application: Application
    
    // MARK: - Init & teardown
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(kEntityNameApplicationSettings, inManagedObjectContext: context)
        self.init(entity: entityDescription!, insertIntoManagedObjectContext: context)
    }
    
    // MARK: - Class functions for create and insert and search
    
    class func get(application: Application, context: NSManagedObjectContext) -> ApplicationSettings? {
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplicationSettings)
        fetchRequest.predicate = NSPredicate(format: "application = %@", application)
        var error: NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        return result?.last as? ApplicationSettings
    }
    
    class func new(application: Application, context: NSManagedObjectContext) -> ApplicationSettings {
        let settings = ApplicationSettings(insertIntoManagedObjectContext: context)
        settings.application = application;
        settings.automaticUpdate = true
        settings.createdAt = NSDate()
        settings.updatedAt = NSDate()
        
        return settings
    }
    
    class func getOrCreateNew(application: Application, context: NSManagedObjectContext) -> ApplicationSettings {
        if let settings = ApplicationSettings.get(application, context: context) {
            return settings
        } else {
            return ApplicationSettings.new(application, context: context)
        }
    }
    
    class func insertNewObjectIntoContext(context: NSManagedObjectContext) -> ApplicationSettings {
        return NSEntityDescription.insertNewObjectForEntityForName(kEntityNameApplicationSettings, inManagedObjectContext: context) as! ApplicationSettings
    }
}

// MARK: - ApplicationUpdater

extension ApplicationSettings {
    
    var shouldUpdateReviews: Bool {
        if !automaticUpdate  {
            return false
        }
        if let reviewsUpdatedAt = reviewsUpdatedAt, nextUpdateAt = nextUpdateAt {
            return nextUpdateAt.compare(NSDate()) == .OrderedAscending
        } else {
            return true
        }
    }
    
    func increaseNewReviews() {
        var int = newReviews.integerValue
        newReviews = NSNumber(integer: int + 1)
    }
    
    func resetNewReviews() {
        newReviews = NSNumber(integer: 0)
    }
}
