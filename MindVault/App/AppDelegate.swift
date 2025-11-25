//----------------------------------------------------------------------------
//File:       AppDelegate.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: App delegate for lifecycle and background tasks
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Register background task
        UnlockService.shared.registerBackgroundTask()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule background task for unlock processing
        UnlockService.shared.scheduleBackgroundTask()
    }
}

