//----------------------------------------------------------------------------
//File:       ItemDetailViewModel.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: ViewModel for item detail view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var decryptedContent: Data?
    @Published var decryptedText: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let item: TimeLockedItem
    private let encryptionService = EncryptionService.shared
    private let storageService = StorageService.shared
    
    init(item: TimeLockedItem) {
        self.item = item
    }
    
    func loadContent() async {
        guard item.unlockStatus == UnlockStatus.unlocked.rawValue else {
            errorMessage = "Content is still locked"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Load encrypted data
            let encryptedData = try storageService.loadEncryptedMedia(for: item.id)
            
            // Decrypt
            let decryptedData = try encryptionService.decrypt(encryptedData: encryptedData, for: item.id)
            
            decryptedContent = decryptedData
            
            // If text, URL, or code, convert to string
            if item.mediaType == MediaType.text.rawValue || 
               item.mediaType == MediaType.url.rawValue ||
               item.mediaType == MediaType.code.rawValue {
                decryptedText = String(data: decryptedData, encoding: .utf8)
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load content: \(error.localizedDescription)"
        }
    }
}

