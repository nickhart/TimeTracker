//
//  TimeInterval+Formatting.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/4/25.
//

import Foundation

extension TimeInterval {
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var formattedDuration: String {
        Self.durationFormatter.string(from: self) ?? "0:00:00"
    }
}
