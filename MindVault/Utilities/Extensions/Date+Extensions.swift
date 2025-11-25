//----------------------------------------------------------------------------
//File:       Date+Extensions.swift
//Project:    MindVault
//Created by: Celaya Solutions, 2025
//Author:     Christopher Celaya <chris@chriscelaya.com>
//Description: Date utility extensions
//Version:    1.0.0
//License:    MIT
//Last Update: November 2025
//----------------------------------------------------------------------------

import Foundation

extension Date {
    func timeRemaining(until date: Date) -> (days: Int, hours: Int, minutes: Int) {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: date)
        return (
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0
        )
    }
    
    func isInFuture(comparedTo date: Date = Date()) -> Bool {
        return self > date
    }
}

