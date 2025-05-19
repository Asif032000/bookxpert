//
//  ItemListView.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import SwiftUI

struct ItemListView: View {
    @StateObject private var viewModel = ItemViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    NavigationLink(destination: ItemEditView(item: item)) {
                        ItemRow(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Items")
            .toolbar {
                Button("Refresh") {
                    Task { await viewModel.fetchFromAPI() }
                }
            }
            .onAppear { viewModel.loadItems() }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        offsets.map { viewModel.items[$0] }.forEach(viewModel.delete)
    }
}

struct ItemRow: View {
    let item: ItemEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name ?? "Unnamed")
                .font(.headline)

            ForEach(item.decodedData.keys.sorted(), id: \.self) { key in
                if let value = item.decodedData[key] {
                    HStack {
                        Text("\(key.capitalized):")
                            .fontWeight(.semibold)
                        Text("\(value)")
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

extension ItemEntity {
    var decodedData: [String: Any] {
        guard
            let json = data,
            let bytes = json.data(using: .utf8),
            let dict  = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any]
        else { return [:] }
        return dict
    }
}
