//----------------------------------------------------------------------------
//File:       UnlockedView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: View for displaying unlocked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct UnlockedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TimeLockedItem.unlockDate, ascending: false)],
        predicate: NSPredicate(format: "unlockStatus == %@", "unlocked"),
        animation: .default)
    private var items: FetchedResults<TimeLockedItem>
    
    var body: some View {
        NavigationStack {
            if items.isEmpty {
                VStack(spacing: 24) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text("No Unlocked Items")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your locked items will appear here when they unlock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Unlocked")
                .navigationBarTitleDisplayMode(.large)
            } else {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            UnlockedItemRow(item: item)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("Unlocked")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct UnlockedItemRow: View {
    let item: TimeLockedItem
    
    var body: some View {
        HStack(spacing: 16) {
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
                Text(mediaTypeDisplayName)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                    
                    Text("Unlocked \(item.unlockDate, style: .relative)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var mediaTypeDisplayName: String {
        MediaType(rawValue: item.mediaType)?.displayName ?? "Unknown"
    }
}

#Preview {
    UnlockedView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

