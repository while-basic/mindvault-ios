//----------------------------------------------------------------------------
//File:       UnlockStatus.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Unlock status enumeration for time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation

enum UnlockStatus: String, CaseIterable, Codable {
    case locked = "locked"
    case unlocked = "unlocked"
    case archived = "archived"
}

