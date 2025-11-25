//----------------------------------------------------------------------------
//File:       VaultGridView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Grid view for locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct VaultGridView: View {
    let items: [TimeLockedItem]
    @Environment(\.managedObjectContext) private var viewContext
    
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    LockedItemCard(item: item)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    VaultView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

