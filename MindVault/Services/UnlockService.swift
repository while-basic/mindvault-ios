//----------------------------------------------------------------------------
//File:       UnlockService.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Background unlock processing service
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import CoreData
import BackgroundTasks

class UnlockService {
    static let shared = UnlockService()
    
    private let backgroundTaskIdentifier = "com.mindvault.unlock"
    
    private init() {}
    
    func processUnlocks(context: NSManagedObjectContext) async {
        let now = Date()
        
        let fetchRequest: NSFetchRequest<TimeLockedItem> = TimeLockedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unlockDate <= %@ AND unlockStatus == %@", now as NSDate, "locked")
        
        do {
            let itemsToUnlock = try context.fetch(fetchRequest)
            
            for item in itemsToUnlock {
                item.unlockStatus = "unlocked"
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Error processing unlocks: \(error)")
        }
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundUnlock(task: task as! BGProcessingTask)
        }
    }
    
    private func handleBackgroundUnlock(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        Task {
            await processUnlocks(context: context)
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour from now
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        try? BGTaskScheduler.shared.submit(request)
    }
}

