//----------------------------------------------------------------------------
//File:       VoiceInputView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Voice memo recording view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import Combine
import CoreData
import AVFoundation

struct VoiceInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CreateItemViewModel
    @StateObject private var recorder = AudioRecorder()
    @State private var recordingURL: URL?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CreateItemViewModel(context: context))
    }
    
    var body: some View {
        Form {
            Section("Voice Memo") {
                if recordingURL != nil {
                    HStack {
                        Image(systemName: "waveform")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Recording saved")
                                .font(.headline)
                            Text(recorder.formattedDuration)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                } else {
                    Text("No recording")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Button {
                        if recorder.isRecording {
                            recorder.stopRecording { url in
                                recordingURL = url
                            }
                        } else {
                            recorder.startRecording()
                        }
                    } label: {
                        HStack {
                            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                        }
                        .foregroundColor(recorder.isRecording ? .red : .primary)
                    }
                    
                    if recorder.isRecording {
                        Spacer()
                        Text(recorder.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
        .navigationTitle("Voice Memo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if recorder.isRecording {
                        recorder.stopRecording { _ in }
                    }
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Lock It") {
                    Task {
                        await saveVoice()
                    }
                }
                .disabled(recordingURL == nil || viewModel.isSaving)
            }
        }
        .onAppear {
            viewModel.selectedMediaType = .voice
            requestMicrophonePermission()
        }
    }
    
    private func saveVoice() async {
        guard let url = recordingURL,
              let audioData = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            try await viewModel.saveVoiceItem(audioData: audioData)
            dismiss()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                // Handle permission denied
            }
        }
    }
}

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var duration: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.duration += 0.1
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        let url = audioRecorder?.url
        audioRecorder = nil
        
        try? AVAudioSession.sharedInstance().setActive(false)
        
        completion(url)
    }
}

#Preview {
    NavigationStack {
        VoiceInputView(context: PersistenceController.preview.container.viewContext)
    }
}

