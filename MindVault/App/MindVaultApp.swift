//----------------------------------------------------------------------------
//File:       MindVaultApp.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Main app entry point for MindVault iOS app
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

@main
struct MindVaultApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    init() {
        // Process any unlocks on app launch
        Task {
            await UnlockService.shared.processUnlocks(context: persistenceController.container.viewContext)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    // Request notification permission on first launch
                    try? await NotificationService.shared.requestAuthorization()
                }
        }
    }
}

