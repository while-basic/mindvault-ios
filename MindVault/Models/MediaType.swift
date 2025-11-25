//----------------------------------------------------------------------------
//File:       MediaType.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Media type enumeration for time-locked items
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation
import SwiftUI

enum MediaType: String, CaseIterable, Codable {
    case text = "text"
    case url = "url"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case voice = "voice"
    case code = "code"
    
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .url: return "URL"
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        case .voice: return "Voice Memo"
        case .code: return "Code File"
        }
    }
    
    var iconName: String {
        switch self {
        case .text: return "text.alignleft"
        case .url: return "link"
        case .image: return "photo"
        case .video: return "video"
        case .audio: return "music.note"
        case .voice: return "mic"
        case .code: return "chevron.left.forwardslash.chevron.right"
        }
    }
    
    var color: Color {
        switch self {
        case .text: return .blue
        case .url: return .purple
        case .image: return .green
        case .video: return .red
        case .audio: return .orange
        case .voice: return .pink
        case .code: return .indigo
        }
    }
    
    var description: String {
        switch self {
        case .text: return "Notes & thoughts"
        case .url: return "Web links"
        case .image: return "Photos"
        case .video: return "Videos"
        case .audio: return "Music & audio"
        case .voice: return "Voice memos"
        case .code: return "Code snippets"
        }
    }
}

