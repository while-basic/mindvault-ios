//----------------------------------------------------------------------------
//File:       CreateItemView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Main creation flow for time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct CreateItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedMediaType: MediaType?
    @State private var showingMediaTypeSelector = true
    var quickCreateType: MediaType? = nil
    
    init(quickCreateType: MediaType? = nil) {
        self.quickCreateType = quickCreateType
    }
    
    var body: some View {
        NavigationStack {
            if let quickType = quickCreateType {
                // Quick create - skip selector for text/URL
                Group {
                    switch quickType {
                    case .text, .url:
                        MediaInputView(mediaType: quickType, context: viewContext)
                    case .image:
                        ImageInputView(context: viewContext)
                    case .video:
                        VideoInputView(context: viewContext)
                    case .audio:
                        AudioInputView(context: viewContext)
                    case .voice:
                        VoiceInputView(context: viewContext)
                    case .code:
                        CodeInputView(context: viewContext)
                    }
                }
                .onDisappear {
                    dismiss()
                }
            } else if showingMediaTypeSelector {
                MediaTypeSelector(selectedType: $selectedMediaType, showingSelector: $showingMediaTypeSelector)
            } else if let mediaType = selectedMediaType {
                Group {
                    switch mediaType {
                    case .text, .url:
                        MediaInputView(mediaType: mediaType, context: viewContext)
                    case .image:
                        ImageInputView(context: viewContext)
                    case .video:
                        VideoInputView(context: viewContext)
                    case .audio:
                        AudioInputView(context: viewContext)
                    case .voice:
                        VoiceInputView(context: viewContext)
                    case .code:
                        CodeInputView(context: viewContext)
                    }
                }
                .onDisappear {
                    if selectedMediaType != nil {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateItemView()
}

