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
                VStack(spacing: 16) {
                    Image(systemName: "lock.open")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No unlocked items yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Your locked items will appear here when they unlock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .navigationTitle("Unlocked")
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
                .navigationTitle("Unlocked")
            }
        }
    }
}

struct UnlockedItemRow: View {
    let item: TimeLockedItem
    
    var body: some View {
        HStack(spacing: 12) {
            if let mediaType = MediaType(rawValue: item.mediaType) {
                Image(systemName: mediaType.iconName)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mediaTypeDisplayName)
                    .font(.headline)
                
                Text("Unlocked \(item.unlockDate, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

