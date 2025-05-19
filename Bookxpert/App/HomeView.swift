//
//  HomeView.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            PDFView()
                .tabItem {
                    Label("PDF", systemImage: "doc.text")
                }

            CameraGalleryView()
                .tabItem {
                    Label("Images", systemImage: "camera")
                }

            ItemListView()
                .tabItem {
                    Label("Items", systemImage: "tray.full")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
