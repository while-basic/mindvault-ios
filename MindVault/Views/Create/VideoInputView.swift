//----------------------------------------------------------------------------
//File:       VideoInputView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Video input view with library and camera
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import PhotosUI
import AVKit

struct VideoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CreateItemViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var showingCamera = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CreateItemViewModel(context: context))
    }
    
    var body: some View {
        Form {
            Section("Video") {
                if let url = videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(12)
                } else {
                    Text("No video selected")
                        .foregroundColor(.secondary)
                }
                
                PhotosPicker(selection: $selectedItem, matching: .videos) {
                    Label("Choose from Library", systemImage: "video")
                }
                
                Button {
                    showingCamera = true
                } label: {
                    Label("Record Video", systemImage: "camera.fill")
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
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Lock It") {
                    Task {
                        await saveVideo()
                    }
                }
                .disabled(videoURL == nil || viewModel.isSaving)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
                    try? data.write(to: tempURL)
                    videoURL = tempURL
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            VideoPicker(videoURL: $videoURL)
        }
        .onAppear {
            viewModel.selectedMediaType = .video
        }
    }
    
    private func saveVideo() async {
        guard let url = videoURL,
              let videoData = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            try await viewModel.saveVideoItem(videoData: videoData)
            dismiss()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        VideoInputView(context: PersistenceController.preview.container.viewContext)
    }
}

