//----------------------------------------------------------------------------
//File:       ContentView.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Main content view with tab navigation
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var authService = AuthenticationService.shared
    @AppStorage("biometricEnabled") private var biometricEnabled = true
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if biometricEnabled && !authService.isAuthenticated {
                AuthenticationView()
            } else {
                TabView(selection: $selectedTab) {
                    VaultView()
                        .tabItem {
                            Label("Vault", systemImage: "lock.shield")
                        }
                        .tag(0)
                    
                    UnlockedView()
                        .tabItem {
                            Label("Unlocked", systemImage: "lock.open")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(2)
                }
                .accentColor(.primary)
            }
        }
        .onChange(of: biometricEnabled) { _, newValue in
            if !newValue {
                authService.logout()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

