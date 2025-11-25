//----------------------------------------------------------------------------
//File:       SettingsView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Settings view for app preferences
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI

struct SettingsView: View {
    @AppStorage("biometricEnabled") private var biometricEnabled = true
    @AppStorage("iCloudBackupEnabled") private var iCloudBackupEnabled = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                } header: {
                    Label("Security", systemImage: "lock.shield.fill")
                } footer: {
                    Text("Require Face ID or Touch ID to access your vault")
                }
                
                Section {
                    Toggle("iCloud Backup", isOn: $iCloudBackupEnabled)
                } header: {
                    Label("Backup", systemImage: "icloud.fill")
                } footer: {
                    Text("Sync your time capsules across all your devices")
                }
                
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://mindvault.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}

