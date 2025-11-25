//----------------------------------------------------------------------------
//File:       AuthenticationView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Biometric authentication view
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @ObservedObject private var authService = AuthenticationService.shared
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.primary)
            
            Text("MindVault")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Protect your time capsules with biometric authentication")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                authenticate()
            } label: {
                HStack {
                    Image(systemName: authService.biometricType == LABiometryType.faceID ? "faceid" : "touchid")
                    Text("Authenticate")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .cornerRadius(12)
            }
            .disabled(isAuthenticating)
            .padding(.horizontal)
            
            if isAuthenticating {
                ProgressView()
                    .padding()
            }
            
            Spacer()
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        errorMessage = nil
        
        let service = authService
        Task { @MainActor in
            do {
                try await service.authenticate(reason: "Authenticate to access your time capsules")
                isAuthenticating = false
            } catch {
                isAuthenticating = false
                if let authError = error as? AuthenticationError,
                   authError != .cancelled {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
}

