//----------------------------------------------------------------------------
//File:       EncryptionService.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: CryptoKit encryption/decryption service
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import CryptoKit

enum EncryptionError: Error {
    case keyGenerationFailed
    case encryptionFailed
    case decryptionFailed
    case keyStorageFailed
    case keyRetrievalFailed
}

class EncryptionService {
    static let shared = EncryptionService()
    
    private init() {}
    
    func encrypt(data: Data, for itemId: UUID) throws -> (encryptedData: Data, key: SymmetricKey) {
        // Generate encryption key
        let key = SymmetricKey(size: .bits256)
        
        // Encrypt using AES-GCM
        let sealedBox = try AES.GCM.seal(data, using: key)
        
        // Combine nonce + ciphertext + tag
        guard let encryptedData = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        
        // Store key in Keychain (will be implemented in KeychainManager)
        try KeychainManager.shared.storeEncryptionKey(key, for: itemId)
        
        return (encryptedData, key)
    }
    
    func decrypt(encryptedData: Data, for itemId: UUID) throws -> Data {
        // Retrieve key from Keychain
        let key = try KeychainManager.shared.retrieveEncryptionKey(for: itemId)
        
        // Extract sealed box from combined data
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        
        // Decrypt
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return decryptedData
    }
    
    func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
}

