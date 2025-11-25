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
        animation: .spring(response: 0.5, dampingFraction: 0.8))
    private var items: FetchedResults<TimeLockedItem>
    
    @AppStorage("vaultViewMode") private var viewMode: String = "grid"
    @State private var showingCreateView = false
    @State private var showingQuickCreate = false
    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("View Mode", selection: $viewMode) {
                            Label("Grid", systemImage: "square.grid.2x2").tag("grid")
                            Label("List", systemImage: "list.bullet").tag("list")
                        }
                    } label: {
                        Image(systemName: viewMode == "grid" ? "square.grid.2x2" : "list.bullet")
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

#Preview {
    VaultView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

