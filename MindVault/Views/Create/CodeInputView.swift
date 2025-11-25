//----------------------------------------------------------------------------
//File:       CodeInputView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Code file input view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers

struct CodeInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CreateItemViewModel
    @State private var selectedFile: URL?
    @State private var showingDocumentPicker = false
    @State private var codePreview: String?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CreateItemViewModel(context: context))
    }
    
    var body: some View {
        Form {
            Section("Code File") {
                if let file = selectedFile {
                    HStack {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(file.lastPathComponent)
                                .font(.headline)
                            if let language = detectLanguage(from: file) {
                                Text(language)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    
                    if let preview = codePreview {
                        ScrollView {
                            Text(preview)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                } else {
                    Text("No code file selected")
                        .foregroundColor(.secondary)
                }
                
                Button {
                    showingDocumentPicker = true
                } label: {
                    Label("Choose Code File", systemImage: "doc.text")
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
        .navigationTitle("Code File")
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
                        await saveCode()
                    }
                }
                .disabled(selectedFile == nil || viewModel.isSaving)
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.sourceCode, .text, .data],
            allowsMultipleSelection: false
        ) { result in
            if let urls = try? result.get(), let url = urls.first {
                selectedFile = url
                loadPreview(from: url)
            }
        }
        .onAppear {
            viewModel.selectedMediaType = .code
        }
    }
    
    private func saveCode() async {
        guard let url = selectedFile,
              let codeData = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            try await viewModel.saveCodeItem(codeData: codeData)
            dismiss()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func loadPreview(from url: URL) {
        if let data = try? Data(contentsOf: url),
           let text = String(data: data, encoding: .utf8) {
            // Show first 1000 characters as preview
            codePreview = String(text.prefix(1000))
        }
    }
    
    private func detectLanguage(from url: URL) -> String? {
        let ext = url.pathExtension.lowercased()
        let languages: [String: String] = [
            "swift": "Swift",
            "js": "JavaScript",
            "ts": "TypeScript",
            "py": "Python",
            "java": "Java",
            "cpp": "C++",
            "c": "C",
            "h": "C Header",
            "m": "Objective-C",
            "html": "HTML",
            "css": "CSS",
            "json": "JSON",
            "xml": "XML",
            "md": "Markdown"
        ]
        return languages[ext]
    }
}

#Preview {
    NavigationStack {
        CodeInputView(context: PersistenceController.preview.container.viewContext)
    }
}

