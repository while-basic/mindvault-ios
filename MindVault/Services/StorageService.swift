//----------------------------------------------------------------------------
//File:       StorageService.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: FileManager service for encrypted media storage
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let baseDirectory: URL
    
    private init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseDirectory = appSupport.appendingPathComponent("MindVault", isDirectory: true)
        
        // Create base directory if it doesn't exist
        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
    }
    
    func getEncryptedMediaDirectory(for itemId: UUID) -> URL {
        let itemDirectory = baseDirectory
            .appendingPathComponent("EncryptedMedia", isDirectory: true)
            .appendingPathComponent(itemId.uuidString, isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: itemDirectory, withIntermediateDirectories: true)
        
        return itemDirectory
    }
    
    func getEncryptedMediaPath(for itemId: UUID) -> String {
        let directory = getEncryptedMediaDirectory(for: itemId)
        let fileURL = directory.appendingPathComponent("media.encrypted")
        return fileURL.path
    }
    
    func getThumbnailPath(for itemId: UUID) -> String? {
        let directory = getEncryptedMediaDirectory(for: itemId)
        let fileURL = directory.appendingPathComponent("thumbnail.png")
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL.path : nil
    }
    
    func saveEncryptedMedia(data: Data, for itemId: UUID) throws {
        let directory = getEncryptedMediaDirectory(for: itemId)
        let fileURL = directory.appendingPathComponent("media.encrypted")
        try data.write(to: fileURL)
    }
    
    func loadEncryptedMedia(for itemId: UUID) throws -> Data {
        let fileURL = URL(fileURLWithPath: getEncryptedMediaPath(for: itemId))
        return try Data(contentsOf: fileURL)
    }
    
    func deleteItemDirectory(for itemId: UUID) throws {
        let directory = getEncryptedMediaDirectory(for: itemId)
        try FileManager.default.removeItem(at: directory)
    }
    
    func saveThumbnail(imageData: Data, for itemId: UUID) throws {
        let directory = getEncryptedMediaDirectory(for: itemId)
        let fileURL = directory.appendingPathComponent("thumbnail.png")
        try imageData.write(to: fileURL)
    }
}

