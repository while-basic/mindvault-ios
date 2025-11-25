//----------------------------------------------------------------------------
//File:       ItemDetailView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Detail view for time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct ItemDetailView: View {
    let item: TimeLockedItem
    @StateObject private var viewModel: ItemDetailViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    init(item: TimeLockedItem) {
        self.item = item
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let mediaType = MediaType(rawValue: item.mediaType) {
                    Text(mediaType.displayName)
                        .font(.title)
                        .padding()
                }
                
                Text("Created: \(item.creationDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if item.unlockStatus == "unlocked" {
                    Text("Unlocked: \(item.unlockDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if let data = viewModel.decryptedContent {
                        if item.mediaType == MediaType.text.rawValue, let text = viewModel.decryptedText {
                            NavigationLink {
                                TextViewer(text: text)
                            } label: {
                                HStack {
                                    Text("View Text")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        } else if item.mediaType == MediaType.url.rawValue, let text = viewModel.decryptedText {
                            NavigationLink {
                                URLViewer(urlString: text)
                            } label: {
                                HStack {
                                    Text("Open URL")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        } else if item.mediaType == MediaType.image.rawValue, let image = UIImage(data: data) {
                            NavigationLink {
                                ImageViewer(image: image)
                            } label: {
                                HStack {
                                    Text("View Image")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        } else if item.mediaType == MediaType.video.rawValue {
                            // Save to temp file for video player
                            if let tempURL = saveToTempFile(data: data, extension: "mov") {
                                NavigationLink {
                                    VideoViewer(videoURL: tempURL)
                                } label: {
                                    HStack {
                                        Text("Play Video")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else if item.mediaType == MediaType.audio.rawValue || item.mediaType == MediaType.voice.rawValue {
                            if let tempURL = saveToTempFile(data: data, extension: "m4a") {
                                NavigationLink {
                                    AudioViewer(audioURL: tempURL)
                                } label: {
                                    HStack {
                                        Text("Play Audio")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else if item.mediaType == MediaType.code.rawValue, let text = String(data: data, encoding: .utf8) {
                            NavigationLink {
                                CodeViewer(code: text, language: detectCodeLanguage(from: item))
                            } label: {
                                HStack {
                                    Text("View Code")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    Text("Unlocks: \(item.unlockDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Text("This content is still locked. It will unlock on the scheduled date.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if item.unlockStatus == "unlocked" {
                await viewModel.loadContent()
            }
        }
    }
    
    private func saveToTempFile(data: Data, extension ext: String) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
    
    private func detectCodeLanguage(from item: TimeLockedItem) -> String? {
        // Could extract from file path or metadata
        return nil
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let item = TimeLockedItem(context: context)
    item.id = UUID()
    item.mediaType = "text"
    item.creationDate = Date()
    item.unlockDate = Date()
    item.unlockStatus = "unlocked"
    item.encryptedFilePath = "/test/path"
    item.iCloudBacked = false
    
    return NavigationStack {
        ItemDetailView(item: item)
    }
    .environment(\.managedObjectContext, context)
}

