//----------------------------------------------------------------------------
//File:       VaultViewModel.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: ViewModel for vault view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import CoreData
import SwiftUI

@MainActor
class VaultViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedMediaType: MediaType?
    @Published var showingDeleteConfirmation = false
    @Published var itemToDelete: TimeLockedItem?
    
    private let context: NSManagedObjectContext
    private let storageService = StorageService.shared
    private let notificationService = NotificationService.shared
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func deleteItem(_ item: TimeLockedItem) async throws {
        // Cancel notification
        notificationService.cancelNotification(for: item.id)
        
        // Delete encrypted file
        try? storageService.deleteItemDirectory(for: item.id)
        
        // Delete encryption key from Keychain
        try? KeychainManager.shared.deleteEncryptionKey(for: item.id)
        
        // Delete Core Data entity
        context.delete(item)
        try context.save()
    }
    
    func editUnlockDate(_ item: TimeLockedItem, newDate: Date) async throws {
        item.unlockDate = newDate
        
        // Update notification
        let title = "Your time capsule is ready!"
        let body = "A \(MediaType(rawValue: item.mediaType)?.displayName ?? "item") has unlocked."
        
        try await notificationService.updateNotification(
            for: item.id,
            unlockDate: newDate,
            title: title,
            body: body,
            customMessage: item.customMessage
        )
        
        try context.save()
    }
}

