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
                Section("Security") {
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                }
                
                Section("Backup") {
                    Toggle("iCloud Backup", isOn: $iCloudBackupEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://mindvault.app/privacy")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

