//
//  NotificationService.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    func requestAuthorization() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func notifyDeletion(id: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Item deleted"
        content.body  = "Deleted object with id: \(id)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        try await UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: UUID().uuidString,
                                        content: content,
                                        trigger: trigger))
    }
}
