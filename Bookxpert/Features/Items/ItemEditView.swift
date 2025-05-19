//
//  ItemEditView.swift
//  Bookxpert
//
//  Created by Asif Habib on 18/05/25.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var item: ItemEntity
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var dataString: String = ""

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $name)
            }
            Section(header: Text("Data (JSON String)")) {
                TextEditor(text: $dataString)
                    .frame(height: 150)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .navigationTitle("Edit Item")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .onAppear {
            name = item.name ?? ""
            dataString = item.data ?? ""
        }
    }

    private func saveChanges() {
        item.name = name
        item.data = dataString

        print("Will save – id:", item.id ?? "nil",
              "name:", item.name ?? "nil",
              "data nil?:", item.data == nil)

        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save item updates: \(error) \(error.localizedDescription)")
        }
    }
}
