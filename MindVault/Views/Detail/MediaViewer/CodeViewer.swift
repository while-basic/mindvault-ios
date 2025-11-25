//----------------------------------------------------------------------------
//File:       CodeViewer.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Code viewer with syntax highlighting (basic)
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct CodeViewer: View {
    let code: String
    let language: String?
    @State private var copied = false
    
    var body: some View {
        ScrollView {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(language ?? "Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        UIPasteboard.general.string = code
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    }
                    
                    ShareLink(item: code) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CodeViewer(code: "func hello() {\n    print(\"Hello, World!\")\n}", language: "Swift")
    }
}

