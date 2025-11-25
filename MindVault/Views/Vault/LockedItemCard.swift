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
import Combine
import CoreData

struct LockedItemCard: View {
    let item: TimeLockedItem
    @State private var timeRemaining: String = ""
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink {
            ItemDetailView(item: item)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Media preview with Liquid Glass blur
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    mediaTypeColor.opacity(0.2),
                                    mediaTypeColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                    
                    if let mediaType = MediaType(rawValue: item.mediaType) {
                        Image(systemName: mediaType.iconName)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(mediaTypeColor.gradient)
                    }
                    
                    // Liquid Glass blur overlay
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            // Subtle shimmer effect
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.1),
                                    .clear,
                                    .white.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .rotationEffect(.degrees(45))
                            .blur(radius: 20)
                        }
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 8) {
                    // Countdown timer
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.tint)
                        
                        Text(timeRemaining)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    // Unlock date
                    Text(item.unlockDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Media type badge
                    if let mediaType = MediaType(rawValue: item.mediaType) {
                        Text(mediaType.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(mediaTypeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(mediaTypeColor.opacity(0.15))
                            }
                    }
                }
                .padding()
            }
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            updateCountdown()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateCountdown()
        }
    }
    
    private var mediaTypeColor: Color {
        guard let mediaType = MediaType(rawValue: item.mediaType) else {
            return .gray
        }
        return mediaType.color
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
        i.mediaType = "image"
        i.creationDate = Date()
        i.unlockDate = Date().addingTimeInterval(86400 * 3)
        i.unlockStatus = "locked"
        i.encryptedFilePath = "/test/path"
        i.iCloudBacked = false
        return i
    }()
    
    LockedItemCard(item: item)
        .padding()
}

