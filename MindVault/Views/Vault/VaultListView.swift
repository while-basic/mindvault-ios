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
    let items: FetchedResults<TimeLockedItem>
    
    var body: some View {
        List {
            ForEach(items) { item in
                LockedItemRow(item: item)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    VaultListView(items: FetchedResults<TimeLockedItem>())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

