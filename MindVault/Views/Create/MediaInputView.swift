//----------------------------------------------------------------------------
//File:       MediaInputView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Media input view for different media types
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct MediaInputView: View {
    let mediaType: MediaType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CreateItemViewModel
    @State private var showingError = false
    
    init(mediaType: MediaType, context: NSManagedObjectContext) {
        self.mediaType = mediaType
        _viewModel = StateObject(wrappedValue: CreateItemViewModel(context: context))
    }
    
    var body: some View {
        Form {
            Section("Content") {
                switch mediaType {
                case .text:
                    TextEditor(text: $viewModel.textContent)
                        .frame(minHeight: 200)
                case .url:
                    TextField("Enter URL", text: $viewModel.urlContent)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                default:
                    EmptyView()
                }
            }
            
            Section("Unlock Date & Time") {
                DatePicker("Unlock Date", selection: $viewModel.unlockDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                
                // Countdown preview
                if viewModel.unlockDate > Date() {
                    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: viewModel.unlockDate)
                    if let days = components.day, let hours = components.hour, let minutes = components.minute {
                        Text("Unlocks in \(days)d \(hours)h \(minutes)m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Optional") {
                TextField("Custom unlock message", text: $viewModel.customMessage)
            }
        }
        .navigationTitle(mediaType.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Lock It") {
                    Task {
                        await saveItem()
                    }
                }
                .disabled(isContentEmpty || viewModel.isSaving)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .onAppear {
            viewModel.selectedMediaType = mediaType
        }
    }
    
    private var isContentEmpty: Bool {
        switch mediaType {
        case .text:
            return viewModel.textContent.isEmpty
        case .url:
            return viewModel.urlContent.isEmpty
        default:
            return true
        }
    }
    
    private func saveItem() async {
        do {
            switch mediaType {
            case .text:
                try await viewModel.saveTextItem()
            case .url:
                try await viewModel.saveURLItem()
            default:
                break
            }
            dismiss()
        } catch {
            showingError = true
        }
    }
}

#Preview {
    NavigationStack {
        MediaInputView(mediaType: .text)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

