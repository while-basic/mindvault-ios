//----------------------------------------------------------------------------
//File:       URLViewer.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: In-app browser for unlocked URLs
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import SafariServices

struct URLViewer: View {
    let urlString: String
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                SafariView(url: url)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Invalid URL")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("URL")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

#Preview {
    NavigationStack {
        URLViewer(urlString: "https://example.com")
    }
}

