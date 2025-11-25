//----------------------------------------------------------------------------
//File:       AudioViewer.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Audio player with controls
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import AVFoundation

struct AudioViewer: View {
    let audioURL: URL
    @StateObject private var player = AudioPlayer()
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundColor(.primary)
            
            Text(audioURL.lastPathComponent)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Playback controls
            HStack(spacing: 40) {
                Button {
                    player.seek(by: -10)
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                
                Button {
                    if player.isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button {
                    player.seek(by: 10)
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
            }
            
            // Time display
            HStack {
                Text(player.formattedCurrentTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(player.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Progress slider
            Slider(value: $player.currentTime, in: 0...player.duration) { editing in
                if !editing {
                    player.seek(to: player.currentTime)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Audio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: audioURL) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            player.load(url: audioURL)
        }
        .onDisappear {
            player.stop()
        }
    }
}

class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    var formattedDuration: String {
        formatTime(duration)
    }
    
    func load(url: URL) {
        player = AVPlayer(url: url)
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            if let duration = self?.player?.currentItem?.duration.seconds {
                self?.duration = duration
            }
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    func seek(by seconds: Double) {
        let newTime = currentTime + seconds
        seek(to: max(0, min(newTime, duration)))
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        AudioViewer(audioURL: URL(string: "https://example.com/audio.mp3")!)
    }
}

