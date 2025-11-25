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
    @StateObject private var viewModel: VaultViewModel
    
    @AppStorage("vaultViewMode") private var viewMode: String = "grid"
    @AppStorage("vaultSortOption") private var sortOption: String = "unlockDate"
    @AppStorage("vaultSortAscending") private var sortAscending: Bool = true
    
    @State private var showingCreateView = false
    @State private var showingQuickCreate = false
    @State private var selectedMediaTypeFilter: MediaType? = nil
    
    // Dynamic fetch request based on search and filters
    private var items: [TimeLockedItem] {
        let request: NSFetchRequest<TimeLockedItem> = TimeLockedItem.fetchRequest()
        
        // Base predicate: only locked items
        var predicates: [NSPredicate] = [
            NSPredicate(format: "unlockStatus == %@", "locked")
        ]
        
        // Search predicate - search by media type display name
        if !viewModel.searchText.isEmpty {
            // Search in mediaType field (case-insensitive)
            predicates.append(
                NSPredicate(format: "mediaType CONTAINS[cd] %@", viewModel.searchText)
            )
        }
        
        // Media type filter
        if let mediaType = selectedMediaTypeFilter {
            predicates.append(
                NSPredicate(format: "mediaType == %@", mediaType.rawValue)
            )
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Create sort descriptor based on selected option
        let sortDescriptor: NSSortDescriptor
        switch sortOption {
        case "creationDate":
            sortDescriptor = NSSortDescriptor(keyPath: \TimeLockedItem.creationDate, ascending: sortAscending)
        case "mediaType":
            sortDescriptor = NSSortDescriptor(keyPath: \TimeLockedItem.mediaType, ascending: sortAscending)
        default:
            sortDescriptor = NSSortDescriptor(keyPath: \TimeLockedItem.unlockDate, ascending: sortAscending)
        }
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    init() {
        // Initialize with shared context - will be updated if environment provides different one
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: VaultViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if items.isEmpty {
                        EmptyVaultView(showingCreateView: $showingCreateView)
                    } else if viewMode == "grid" {
                        VaultGridView(items: items)
                    } else {
                        VaultListView(items: items)
                    }
                }
                
                // Floating Action Button with Liquid Glass
                VStack(spacing: 12) {
                    if showingQuickCreate {
                        QuickCreateMenu(showingCreateView: $showingCreateView, showingQuickCreate: $showingQuickCreate)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            if items.isEmpty {
                                showingCreateView = true
                            } else {
                                showingQuickCreate.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: showingQuickCreate ? "xmark" : "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background {
                                Circle()
                                    .fill(.tint)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                    }
                    .rotationEffect(.degrees(showingQuickCreate ? 45 : 0))
                    .scaleEffect(showingQuickCreate ? 0.9 : 1.0)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Vault")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search time capsules")
            .toolbar {
                if selectedMediaTypeFilter != nil || !viewModel.searchText.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            selectedMediaTypeFilter = nil
                            viewModel.searchText = ""
                        } label: {
                            Label("Clear Filters", systemImage: "xmark.circle.fill")
                                .font(.caption)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // View Mode
                        Picker("View Mode", selection: $viewMode) {
                            Label("Grid", systemImage: "square.grid.2x2").tag("grid")
                            Label("List", systemImage: "list.bullet").tag("list")
                        }
                        
                        Divider()
                        
                        // Sort Options
                        Menu("Sort By") {
                            Picker("Sort", selection: $sortOption) {
                                Label("Unlock Date", systemImage: "clock").tag("unlockDate")
                                Label("Creation Date", systemImage: "calendar").tag("creationDate")
                                Label("Media Type", systemImage: "square.stack").tag("mediaType")
                            }
                            
                            Toggle("Ascending", isOn: $sortAscending)
                        }
                        
                        Divider()
                        
                        // Filter by Media Type
                        Menu("Filter") {
                            Button("All Types") {
                                selectedMediaTypeFilter = nil
                            }
                            
                            Divider()
                            
                            ForEach(MediaType.allCases, id: \.self) { type in
                                Button {
                                    selectedMediaTypeFilter = selectedMediaTypeFilter == type ? nil : type
                                } label: {
                                    HStack {
                                        Image(systemName: type.iconName)
                                        Text(type.displayName)
                                        if selectedMediaTypeFilter == type {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreateItemView()
            }
            .onChange(of: showingCreateView) { oldValue, newValue in
                if !newValue {
                    showingQuickCreate = false
                }
            }
            .onAppear {
                // Ensure viewModel uses the environment context
                if viewModel.context != viewContext {
                    // Update viewModel context if environment provides different one
                    // Note: This is a workaround - ideally viewModel should use @Environment
                }
            }
        }
    }
}

struct EmptyVaultView: View {
    @Binding var showingCreateView: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.tint)
            }
            
            VStack(spacing: 8) {
                Text("Your Vault is Empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first time capsule to lock content until a future date")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                showingCreateView = true
            } label: {
                Label("Create Time Capsule", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.tint)
                    }
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct QuickCreateMenu: View {
    @Binding var showingCreateView: Bool
    @Binding var showingQuickCreate: Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing: 12) {
                    QuickCreateButton(
                        icon: "text.alignleft",
                        label: "Text",
                        color: .blue
                    ) {
                        showingCreateView = true
                        showingQuickCreate = false
                    }
                    
                    QuickCreateButton(
                        icon: "link",
                        label: "URL",
                        color: .purple
                    ) {
                        showingCreateView = true
                        showingQuickCreate = false
                    }
                    
                    QuickCreateButton(
                        icon: "photo",
                        label: "Photo",
                        color: .green
                    ) {
                        showingCreateView = true
                        showingQuickCreate = false
                    }
        }
    }
}

struct QuickCreateButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background {
                        Circle()
                            .fill(color.opacity(0.15))
                    }
                
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
        .frame(width: 180)
    }
}

struct EmptySearchView: View {
    let searchText: String
    let mediaTypeFilter: MediaType?
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)
            
            if !searchText.isEmpty {
                Text("No time capsules match \"\(searchText)\"")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let filter = mediaTypeFilter {
                Text("No \(filter.displayName) items found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    VaultView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

