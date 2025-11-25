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
}

