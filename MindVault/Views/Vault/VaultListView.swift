//----------------------------------------------------------------------------
//File:       VaultListView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: List view for locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct VaultListView: View {
    let items: [TimeLockedItem]
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditView = false
    @State private var itemToEdit: TimeLockedItem?
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    LockedItemRow(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        itemToEdit = item
                        showingEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showingEditView) {
            if let item = itemToEdit {
                EditItemView(item: item, viewContext: viewContext)
            }
        }
    }
    
    private func deleteItem(_ item: TimeLockedItem) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}

#Preview {
    VaultView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

