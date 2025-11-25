//----------------------------------------------------------------------------
//File:       CreateItemViewModel.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: ViewModel for creating time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
class CreateItemViewModel: ObservableObject {
    @Published var selectedMediaType: MediaType?
    @Published var textContent: String = ""
    @Published var urlContent: String = ""
    @Published var unlockDate: Date = Date().addingTimeInterval(86400)
    @Published var customMessage: String = ""
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    private let context: NSManagedObjectContext
    private let encryptionService = EncryptionService.shared
    private let storageService = StorageService.shared
    private let notificationService = NotificationService.shared
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveTextItem() async throws {
        guard !textContent.isEmpty else {
            throw CreateError.emptyContent
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            let textData = textContent.data(using: .utf8)!
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: textData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.text.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "A \(MediaType.text.displayName) item has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveURLItem() async throws {
        guard !urlContent.isEmpty,
              URL(string: urlContent) != nil else {
            throw CreateError.invalidURL
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            let urlData = urlContent.data(using: .utf8)!
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: urlData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.url.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "A \(MediaType.url.displayName) item has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveImageItem(imageData: Data) async throws {
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: imageData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Generate and save thumbnail
            if let image = UIImage(data: imageData),
               let thumbnailData = image.jpegData(compressionQuality: 0.3) {
                try? storageService.saveThumbnail(imageData: thumbnailData, for: itemId)
            }
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.image.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "An \(MediaType.image.displayName) has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveVideoItem(videoData: Data) async throws {
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: videoData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.video.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "A \(MediaType.video.displayName) has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveAudioItem(audioData: Data) async throws {
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: audioData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.audio.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "An \(MediaType.audio.displayName) file has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveVoiceItem(audioData: Data) async throws {
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: audioData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.voice.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "A \(MediaType.voice.displayName) has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func saveCodeItem(codeData: Data) async throws {
        isSaving = true
        errorMessage = nil
        
        do {
            let itemId = UUID()
            
            // Encrypt content
            let (encryptedData, _) = try encryptionService.encrypt(data: codeData, for: itemId)
            
            // Save encrypted file
            try storageService.saveEncryptedMedia(data: encryptedData, for: itemId)
            
            // Create Core Data entity
            let item = TimeLockedItem(context: context)
            item.id = itemId
            item.mediaType = MediaType.code.rawValue
            item.creationDate = Date()
            item.unlockDate = unlockDate
            item.unlockStatus = UnlockStatus.locked.rawValue
            item.encryptedFilePath = storageService.getEncryptedMediaPath(for: itemId)
            item.customMessage = customMessage.isEmpty ? nil : customMessage
            item.iCloudBacked = false
            
            try context.save()
            
            // Schedule notification
            try await notificationService.scheduleUnlockNotification(
                for: itemId,
                unlockDate: unlockDate,
                title: "Your time capsule is ready!",
                body: "A \(MediaType.code.displayName) has unlocked.",
                customMessage: customMessage.isEmpty ? nil : customMessage
            )
            
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func reset() {
        selectedMediaType = nil
        textContent = ""
        urlContent = ""
        unlockDate = Date().addingTimeInterval(86400)
        customMessage = ""
        errorMessage = nil
    }
}

enum CreateError: LocalizedError {
    case emptyContent
    case invalidURL
    case encryptionFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Content cannot be empty"
        case .invalidURL:
            return "Please enter a valid URL"
        case .encryptionFailed:
            return "Failed to encrypt content"
        case .saveFailed:
            return "Failed to save item"
        }
    }
}

