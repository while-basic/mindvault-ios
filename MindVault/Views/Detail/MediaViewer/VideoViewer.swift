//----------------------------------------------------------------------------
//File:       VideoViewer.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Video player with AVKit
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import AVKit

struct VideoViewer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: videoURL) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            player = AVPlayer(url: videoURL)
        }
    }
}

#Preview {
    NavigationStack {
        VideoViewer(videoURL: URL(string: "https://example.com/video.mp4")!)
    }
}

