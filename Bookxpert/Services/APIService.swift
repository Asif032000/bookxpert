//
//  APIService.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import Foundation
struct APIService {
    private let endpoint = URL(string: "https://api.restful-api.dev/objects")!

    func fetchObjects() async throws -> [ItemDTO] {
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        return try JSONDecoder().decode([ItemDTO].self, from: data)
    }

    func syncToCoreData() async throws {
        let items = try await fetchObjects()
        let ctx = PersistenceController.shared.context
        try await ctx.perform {
            items.forEach { dto in
                let entity = ItemEntity(context: ctx)
                entity.id   = dto.id
                entity.name = dto.name
                entity.data = dto.data
            }
            try ctx.save()
        }
    }

    func delete(id: String) async throws {
        let delURL = endpoint.appendingPathComponent(id)
        var request = URLRequest(url: delURL)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.upload(for: request, from: Data())
        try await NotificationService().notifyDeletion(id: id)
    }
}
