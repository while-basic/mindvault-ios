//----------------------------------------------------------------------------
//File:       TextViewer.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Text content viewer for unlocked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct TextViewer: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Text(text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Text")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: text) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TextViewer(text: "This is a sample text content that was locked and has now been unlocked.")
    }
}

