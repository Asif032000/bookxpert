//
//  AuthView.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Welcome")
                .font(.largeTitle)
                .bold()

            Button(action: signIn) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Sign in with Google")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading)

            if let error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }

    func signIn() {
        Task {
            isLoading = true
            do {
                try await authService.signIn()
            } catch {
                self.error = "Sign in failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
