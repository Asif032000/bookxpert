//
//  RootView.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import SwiftUI
struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.user != nil {
                HomeView()        // main app flow
            } else {
                AuthView()        // sign-in screen
            }
        }
        .onAppear {
            // Additional setup if needed
        }
    }
}

