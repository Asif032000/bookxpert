//
//  AuthService.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit


final class AuthService: ObservableObject {
    @MainActor @Published private(set) var user: User? = nil
    
    @MainActor
    init() {
        self.user = Auth.auth().currentUser   // persisted between launches
        Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in self.user = user }
        }
    }

    @MainActor
    func signIn() async throws {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let config = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {

            let config = GIDConfiguration(clientID: "672866176628-j4jml9ol60v1m611oqd0vtdcsh31krhd.apps.googleusercontent.com")
            GIDSignIn.sharedInstance.configuration = config
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
            // Use `result.user` here
            let credential = GoogleAuthProvider.credential(withIDToken: result.user.idToken!.tokenString,
                                                           accessToken: result.user.accessToken.tokenString)
            try await Auth.auth().signIn(with: credential)
            try await saveToCoreData(user: Auth.auth().currentUser)
        }
        
    }

    private func saveToCoreData(user: FirebaseAuth.User?) throws {
        guard let user else { return }
        let ctx = PersistenceController.shared.context
        let entity = CDUser(context: ctx)
        entity.uid  = user.uid
        entity.name = user.displayName
        entity.email = user.email
        try ctx.save()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
