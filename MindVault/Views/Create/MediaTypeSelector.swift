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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(MediaType.allCases, id: \.self) { mediaType in
                    MediaTypeCard(
                        mediaType: mediaType,
                        action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedType = mediaType
                                showingSelector = false
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Create Time Capsule")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct MediaTypeCard: View {
    let mediaType: MediaType
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(mediaType.color.opacity(0.15))
                        .frame(height: 120)
                    
                    Image(systemName: mediaType.iconName)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(mediaType.color.gradient)
                }
                
                VStack(spacing: 4) {
                    Text(mediaType.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(mediaType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}


#Preview {
    NavigationStack {
        MediaTypeSelector(selectedType: .constant(nil), showingSelector: .constant(true))
    }
}

