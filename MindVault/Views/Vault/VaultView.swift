//----------------------------------------------------------------------------
//File:       VaultView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Main vault view showing locked items in grid or list
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct VaultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TimeLockedItem.unlockDate, ascending: true)],
        predicate: NSPredicate(format: "unlockStatus == %@", "locked"),
        animation: .default)
    private var items: FetchedResults<TimeLockedItem>
    
    @AppStorage("vaultViewMode") private var viewMode: String = "grid"
    @State private var showingCreateView = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewMode == "grid" {
                    VaultGridView(items: items)
                } else {
                    VaultListView(items: items)
                }
            }
            .navigationTitle("MindVault")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "square.grid.2x2").tag("grid")
                        Image(systemName: "list.bullet").tag("list")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreateItemView()
            }
        }
    }
}

#Preview {
    VaultView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

