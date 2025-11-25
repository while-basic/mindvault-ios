//----------------------------------------------------------------------------
//File:       EditItemView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: View for editing time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let item: TimeLockedItem
    @StateObject private var viewModel: VaultViewModel
    
    @State private var unlockDate: Date
    @State private var customMessage: String
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage: String?
    
    init(item: TimeLockedItem, context: NSManagedObjectContext) {
        self.item = item
        _viewModel = StateObject(wrappedValue: VaultViewModel(context: context))
        _unlockDate = State(initialValue: item.unlockDate)
        _customMessage = State(initialValue: item.customMessage ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Unlock Date", selection: $unlockDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    
                    if unlockDate > Date() {
                        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: unlockDate)
                        if let days = components.day, let hours = components.hour, let minutes = components.minute {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(.tint)
                                Text("Unlocks in \(days)d \(hours)h \(minutes)m")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    }
                } header: {
                    Label("Unlock Date & Time", systemImage: "calendar")
                } footer: {
                    Text("The notification will be updated to match the new unlock date")
                }
                
                Section {
                    TextField("Custom unlock message", text: $customMessage, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Label("Custom Message", systemImage: "message")
                } footer: {
                    Text("Optional message shown when the item unlocks")
                }
                
                Section {
                    if let mediaType = MediaType(rawValue: item.mediaType) {
                        HStack {
                            Image(systemName: mediaType.iconName)
                                .foregroundStyle(mediaType.color)
                            Text(mediaType.displayName)
                        }
                        
                        Text("Created: \(item.creationDate, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Item Info", systemImage: "info.circle")
                }
            }
            .navigationTitle("Edit Time Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving || unlockDate == item.unlockDate && customMessage == (item.customMessage ?? ""))
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    private func saveChanges() {
        isSaving = true
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        Task {
            do {
                // Update unlock date if changed
                if unlockDate != item.unlockDate {
                    try await viewModel.editUnlockDate(item, newDate: unlockDate)
                }
                
                // Update custom message
                item.customMessage = customMessage.isEmpty ? nil : customMessage
                
                // Save context
                try viewContext.save()
                
                // Success haptic
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let item = TimeLockedItem(context: context)
    item.id = UUID()
    item.mediaType = "text"
    item.creationDate = Date()
    item.unlockDate = Date().addingTimeInterval(86400)
    item.unlockStatus = "locked"
    item.encryptedFilePath = "/test/path"
    item.customMessage = "Test message"
    
    return EditItemView(item: item, context: context)
}

