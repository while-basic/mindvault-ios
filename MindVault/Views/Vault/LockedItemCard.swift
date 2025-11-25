//----------------------------------------------------------------------------
//File:       LockedItemCard.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Card component for displaying locked items in grid view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct LockedItemCard: View {
    let item: TimeLockedItem
    @State private var timeRemaining: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Blurred preview or media type icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                
                if let mediaType = MediaType(rawValue: item.mediaType) {
                    Image(systemName: mediaType.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 160)
            .overlay {
                // Blur overlay for locked content
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            }
            
            // Countdown timer
            Text(timeRemaining)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Unlock date
            Text(item.unlockDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .onAppear {
            updateCountdown()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateCountdown()
        }
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
    let context = PersistenceController.preview.container.viewContext
    let item = TimeLockedItem(context: context)
    item.id = UUID()
    item.mediaType = "image"
    item.creationDate = Date()
    item.unlockDate = Date().addingTimeInterval(86400 * 3) // 3 days from now
    item.unlockStatus = "locked"
    item.encryptedFilePath = "/test/path"
    item.iCloudBacked = false
    
    return LockedItemCard(item: item)
        .padding()
}

