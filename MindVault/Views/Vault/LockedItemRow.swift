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
import Combine
import CoreData

struct LockedItemRow: View {
    let item: TimeLockedItem
    @State private var timeRemaining: String = ""
    
    var body: some View {
        HStack(spacing: 16) {
            // Media type icon with Liquid Glass
            if let mediaType = MediaType(rawValue: item.mediaType) {
                ZStack {
                    Circle()
                        .fill(mediaType.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: mediaType.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(mediaType.color.gradient)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(mediaTypeDisplayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundStyle(.tint)
                        
                        Text(timeRemaining)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(item.unlockDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
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
                    timeRemaining = "\(days)d \(hours)h"
                } else if hours > 0 {
                    timeRemaining = "\(hours)h \(minutes)m"
                } else {
                    timeRemaining = "\(minutes)m"
                }
            }
        } else {
            timeRemaining = "Unlocked"
        }
    }
}

#Preview {
    let item: TimeLockedItem = {
        let context = PersistenceController.preview.container.viewContext
        let i = TimeLockedItem(context: context)
        i.id = UUID()
        i.mediaType = "text"
        i.creationDate = Date()
        i.unlockDate = Date().addingTimeInterval(86400 * 2)
        i.unlockStatus = "locked"
        i.encryptedFilePath = "/test/path"
        i.iCloudBacked = false
        return i
    }()
    
    LockedItemRow(item: item)
        .padding()
}

