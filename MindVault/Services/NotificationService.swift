//----------------------------------------------------------------------------
//File:       NotificationService.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Local notification scheduling service
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleUnlockNotification(for itemId: UUID, unlockDate: Date, title: String, body: String, customMessage: String?) async throws {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = customMessage ?? body
        content.sound = .default
        content.userInfo = ["itemId": itemId.uuidString]
        
        // Create date components for trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: unlockDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: itemId.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    func cancelNotification(for itemId: UUID) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [itemId.uuidString])
    }
    
    func updateNotification(for itemId: UUID, unlockDate: Date, title: String, body: String, customMessage: String?) async throws {
        // Cancel existing and schedule new
        cancelNotification(for: itemId)
        try await scheduleUnlockNotification(for: itemId, unlockDate: unlockDate, title: title, body: body, customMessage: customMessage)
    }
}

