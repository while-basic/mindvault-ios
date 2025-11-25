//----------------------------------------------------------------------------
//File:       TimeLockedItem+CoreDataProperties.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Core Data properties extension for TimeLockedItem
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import CoreData

extension TimeLockedItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeLockedItem> {
        return NSFetchRequest<TimeLockedItem>(entityName: "TimeLockedItem")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var mediaType: String
    @NSManaged public var creationDate: Date
    @NSManaged public var unlockDate: Date
    @NSManaged public var unlockStatus: String
    @NSManaged public var encryptedFilePath: String
    @NSManaged public var customMessage: String?
    @NSManaged public var metadata: Data?
    @NSManaged public var iCloudBacked: Bool
    @NSManaged public var thumbnailPath: String?
}

extension TimeLockedItem : Identifiable {
    
}

