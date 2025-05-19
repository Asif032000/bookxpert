//
//  SettingsView.swift
//  Bookxpert
//
//  Created by Asif Habib on 18/05/25.
//

import SwiftUI
import UserNotifications

enum ThemeOption: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static func from(scheme: ColorScheme?) -> ThemeOption {
        switch scheme {
        case .some(.light): return .light
        case .some(.dark): return .dark
        default: return .system
        }
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @EnvironmentObject var themeManager: ThemeManager
    @State private var permissionStatus: UNAuthorizationStatus?

    @State private var selectedTheme: ThemeOption = .system

    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { isEnabled in
                        if isEnabled {
                            requestNotificationPermission()
                        }
                    }

                if let status = permissionStatus {
                    Text("System Permission: \(statusDescription(for: status))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(ThemeOption.allCases) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedTheme) { newValue in
                    themeManager.selectedScheme = newValue.colorScheme
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            getNotificationPermissionStatus()
            selectedTheme = ThemeOption.from(scheme: themeManager.selectedScheme)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                }
                getNotificationPermissionStatus()
            }
        }
    }

    private func getNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
            }
        }
    }

    private func statusDescription(for status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}

