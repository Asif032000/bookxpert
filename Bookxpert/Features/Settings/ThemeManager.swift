//
//  ThemeViewModel.swift
//  Bookxpert
//
//  Created by Asif Habib on 20/05/25.
//

import Foundation
import SwiftUICore
class ThemeManager: ObservableObject {
    @Published var selectedScheme: ColorScheme? {
        didSet {
            if let scheme = selectedScheme {
                UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: "theme")
            } else {
                UserDefaults.standard.removeObject(forKey: "theme")
            }
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "theme")
        if saved == "dark" {
            selectedScheme = .dark
        } else if saved == "light" {
            selectedScheme = .light
        } else {
            selectedScheme = nil // Follow system
        }
    }
}
