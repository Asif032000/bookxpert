//
//  BookxpertApp.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      
      // Request permission
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          if let error = error {
              print("Notification permission error: \(error.localizedDescription)")
          } else {
              print("Notification permission granted: \(granted)")
              UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
          }
      }
      
      UNUserNotificationCenter.current().delegate = self
    return true
  }
}

@main
struct BookxpertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authService = AuthService()
    @StateObject private var themeManager = ThemeManager()
    var body: some Scene {
        
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedScheme)
//                .preferredColorScheme(.light)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
