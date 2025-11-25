//----------------------------------------------------------------------------
//File:       KeychainManager.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Keychain operations for storing encryption keys
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import CryptoKit
import Security

enum KeychainError: Error {
    case storeFailed
    case retrieveFailed
    case deleteFailed
    case keyNotFound
}

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.mindvault.encryption"
    
    private init() {}
    
    func storeEncryptionKey(_ key: SymmetricKey, for itemId: UUID) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        let account = itemId.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing key if present
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed
        }
    }
    
    func retrieveEncryptionKey(for itemId: UUID) throws -> SymmetricKey {
        let account = itemId.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw KeychainError.keyNotFound
        }
        
        return SymmetricKey(data: keyData)
    }
    
    func deleteEncryptionKey(for itemId: UUID) throws {
        let account = itemId.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

