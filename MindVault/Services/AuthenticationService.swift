//----------------------------------------------------------------------------
//File:       AuthenticationService.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Biometric authentication service using LocalAuthentication
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import Combine
import LocalAuthentication

enum AuthenticationError: Error {
    case notAvailable
    case failed
    case cancelled
    case notConfigured
}

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var biometricType: LABiometryType = .none
    
    private let context = LAContext()
    
    private init() {
        checkBiometricAvailability()
    }
    
    func checkBiometricAvailability() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }
    
    func authenticate(reason: String = "Authenticate to access MindVault") async throws {
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            // Fallback to device passcode
            return try await authenticateWithPasscode(reason: reason)
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                await MainActor.run {
                    isAuthenticated = true
                }
            }
        } catch {
            // Fallback to passcode on biometric failure
            try await authenticateWithPasscode(reason: reason)
        }
    }
    
    private func authenticateWithPasscode(reason: String) async throws {
        let passcodeContext = LAContext()
        guard passcodeContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            throw AuthenticationError.notAvailable
        }
        
        do {
            let success = try await passcodeContext.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            
            if success {
                await MainActor.run {
                    isAuthenticated = true
                }
            }
        } catch {
            if (error as NSError).code == LAError.userCancel.rawValue {
                throw AuthenticationError.cancelled
            } else {
                throw AuthenticationError.failed
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
}

