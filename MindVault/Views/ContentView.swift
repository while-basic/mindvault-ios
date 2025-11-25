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
    @ObservedObject private var authService = AuthenticationService.shared
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
                            Label("Vault", systemImage: "lock.shield.fill")
                        }
                        .tag(0)
                    
                    UnlockedView()
                        .tabItem {
                            Label("Unlocked", systemImage: "lock.open.fill")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(2)
                }
                .tint(.primary)
            }
        }
        .onChange(of: biometricEnabled) { oldValue, newValue in
            if !newValue {
                AuthenticationService.shared.logout()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

