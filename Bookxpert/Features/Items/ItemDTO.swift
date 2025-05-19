//
//  ItemDTO.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import CoreData

struct ItemDTO: Codable {
    let id: String
    let name: String
    let data: String?

    func toEntity(in context: NSManagedObjectContext) -> ItemEntity {
        let entity = ItemEntity(context: context)
        entity.id = id
        entity.name = name
        entity.data = data
        return entity
    }
}
