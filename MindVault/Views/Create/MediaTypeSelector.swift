//----------------------------------------------------------------------------
//File:       MediaTypeSelector.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Media type selection interface
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct MediaTypeSelector: View {
    @Binding var selectedType: MediaType?
    @Binding var showingSelector: Bool
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(MediaType.allCases, id: \.self) { mediaType in
                    Button {
                        selectedType = mediaType
                        showingSelector = false
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: mediaType.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(.primary)
                            
                            Text(mediaType.displayName)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Select Media Type")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MediaTypeSelector(selectedType: .constant(nil), showingSelector: .constant(true))
    }
}

