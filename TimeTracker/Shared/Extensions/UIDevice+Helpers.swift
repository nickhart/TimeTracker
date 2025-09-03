//
//  UIDevice+Helpers.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import UIKit

extension UIDevice {
    static var isPhone: Bool {
        current.userInterfaceIdiom == .phone
    }

    static var isPad: Bool {
        current.userInterfaceIdiom == .pad
    }
}
