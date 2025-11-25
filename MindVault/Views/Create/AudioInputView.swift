//----------------------------------------------------------------------------
//File:       AudioInputView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Audio input view with file picker
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers

struct AudioInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CreateItemViewModel
    @State private var selectedFile: URL?
    @State private var showingDocumentPicker = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CreateItemViewModel(context: context))
    }
    
    var body: some View {
        Form {
            Section("Audio File") {
                if let file = selectedFile {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(file.lastPathComponent)
                                .font(.headline)
                            if let fileSize = getFileSize(url: file) {
                                Text(fileSize)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                } else {
                    Text("No audio file selected")
                        .foregroundColor(.secondary)
                }
                
                Button {
                    showingDocumentPicker = true
                } label: {
                    Label("Choose Audio File", systemImage: "folder")
                }
            }
            
            Section("Unlock Date & Time") {
                DatePicker("Unlock Date", selection: $viewModel.unlockDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                
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
        .navigationTitle("Audio")
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
                        await saveAudio()
                    }
                }
                .disabled(selectedFile == nil || viewModel.isSaving)
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.audio, .mp3, .m4a, .wav],
            allowsMultipleSelection: false
        ) { result in
            if let urls = try? result.get(), let url = urls.first {
                selectedFile = url
            }
        }
        .onAppear {
            viewModel.selectedMediaType = .audio
        }
    }
    
    private func saveAudio() async {
        guard let url = selectedFile,
              let audioData = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            try await viewModel.saveAudioItem(audioData: audioData)
            dismiss()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func getFileSize(url: URL) -> String? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? Int64 {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useKB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: size)
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        AudioInputView(context: PersistenceController.preview.container.viewContext)
    }
}

