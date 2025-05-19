//
//  ItemViewModel.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import CoreData
import UserNotifications

class ItemViewModel: ObservableObject {
    @Published var items: [ItemEntity] = []
    let context = PersistenceController.shared.container.viewContext

    func fetchFromAPI() async {
        guard let url = URL(string: "https://api.restful-api.dev/objects") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([APIItem].self, from: data)
            saveToCoreData(items: decoded)
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    func saveToCoreData(items: [APIItem]) {
        for item in items {
            let entity = ItemEntity(context: context)
            entity.id = item.id
            entity.name = item.name

            if let data = item.data {
                if let jsonData = try? JSONEncoder().encode(data),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    entity.data = jsonString
                }
            } else {
                entity.data = nil
            }
        }

        do {
            try context.save()
            loadItems()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func loadItems() {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        if let result = try? context.fetch(request) {
            DispatchQueue.main.async {
               self.items = result
           }
        }
    }

    func delete(item: ItemEntity) {
        let deletedItemName = item.name ?? "Unknown"
        let deletedItemDetails = formatItemData(item.data)

        context.delete(item)
        try? context.save()
        loadItems()

        sendDeleteNotification(name: deletedItemName, details: deletedItemDetails)
    }

    private func formatItemData(_ jsonString: String?) -> String {
        guard
            let jsonString = jsonString,
            let data = jsonString.data(using: .utf8),
            let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return "No details available"
        }

        return jsonDict.map { "\($0.key.capitalized): \($0.value)" }
                       .joined(separator: "\n")
    }

    func saveItems(_ items: [ItemDTO]) {
        let context = PersistenceController.shared.context
        for dto in items {
            _ = dto.toEntity(in: context)
        }

        try? context.save()
    }

    
    private func sendDeleteNotification(name: String, details: String) {
        let content = UNMutableNotificationContent()
        content.title = "Item Deleted"
        content.body = "\(name)\n\(details)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        if UserDefaults.standard.bool(forKey: "notificationsEnabled") {
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification error: \(error.localizedDescription)")
                } else {
                    print("Notification sent for: \(name)")
                }
            }
        }
    }

}

struct ItemData: Codable {
    let color: String
    let capacity: String
}
struct APIItem: Codable {
    let id: String
    let name: String
    let data: [String: JSONValue]?
}

enum JSONValue: Codable {
    case string(String), int(Int), double(Double), bool(Bool), null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let b = try? c.decode(Bool.self)   { self = .bool(b)   }
        else if let i = try? c.decode(Int.self)    { self = .int(i)    }
        else if let d = try? c.decode(Double.self) { self = .double(d) }
        else { self = .string(try c.decode(String.self)) }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v):  try c.encode(v)
        case .int(let v):     try c.encode(v)
        case .double(let v):  try c.encode(v)
        case .bool(let v):    try c.encode(v)
        case .null:           try c.encodeNil()
        }
    }
    
    func decodeItemData(_ jsonString: String?) -> [String: Any] {
        guard
            let jsonString = jsonString,
            let data = jsonString.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return [:]
        }
        return dict
    }
}

extension ItemEntity {
    var dataMap: [String: JSONValue]? {
        guard let json = data,
              let bytes = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([String: JSONValue].self, from: bytes)
    }
}

extension ItemEntity {
    var color: String? {
        guard let map = dataMap else { return nil }
        switch map["color"] ?? map["Color"] {
        case .string(let s): return s
        default:             return nil
        }
    }

    var capacity: String? {
        guard let map = dataMap else { return nil }
        // some items use "capacity", others "Capacity", one uses "capacity GB"
        let keys = ["capacity", "Capacity", "capacity GB"]
        for k in keys {
            if case .string(let s)? = map[k] { return s }
            if case .int(let i)?    = map[k] { return "\(i)" }
            if case .double(let d)? = map[k] { return "\(d)" }
        }
        return nil
    }
}
