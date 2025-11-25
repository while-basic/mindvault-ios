//----------------------------------------------------------------------------
//File:       LockedItemRow.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Row component for displaying locked items in list view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct LockedItemRow: View {
    let item: TimeLockedItem
    @State private var timeRemaining: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Media type icon
            if let mediaType = MediaType(rawValue: item.mediaType) {
                Image(systemName: mediaType.iconName)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mediaTypeDisplayName)
                    .font(.headline)
                
                Text(timeRemaining)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.unlockDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .onAppear {
            updateCountdown()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateCountdown()
        }
    }
    
    private var mediaTypeDisplayName: String {
        MediaType(rawValue: item.mediaType)?.displayName ?? "Unknown"
    }
    
    private func updateCountdown() {
        let now = Date()
        let unlockDate = item.unlockDate
        
        if unlockDate > now {
            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: unlockDate)
            if let days = components.day, let hours = components.hour, let minutes = components.minute {
                if days > 0 {
                    timeRemaining = "\(days) days, \(hours) hours"
                } else if hours > 0 {
                    timeRemaining = "\(hours) hours, \(minutes) minutes"
                } else {
                    timeRemaining = "\(minutes) minutes"
                }
            }
        } else {
            timeRemaining = "Unlocked"
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let item = TimeLockedItem(context: context)
    item.id = UUID()
    item.mediaType = "text"
    item.creationDate = Date()
    item.unlockDate = Date().addingTimeInterval(86400 * 2) // 2 days from now
    item.unlockStatus = "locked"
    item.encryptedFilePath = "/test/path"
    item.iCloudBacked = false
    
    return LockedItemRow(item: item)
        .padding()
}

