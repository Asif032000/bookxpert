//
//  CameraGalleryView.swift
//  Bookxpert
//
//  Created by Asif Habib on 16/05/25.
//

import Foundation
import SwiftUI

struct CameraGalleryView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }

            HStack {
                Button("Camera") {
                    sourceType = .camera
                    showImagePicker = true
                }
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                Button("Gallery") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, image: Binding(
                get: { selectedImage },
                set: { newImage, _ in
                    selectedImage = newImage
                    if let img = newImage {
                        Task {
                            try? await ImageService.shared.saveToDisk(img)
                        }
                    }
                }
            ))
        }
        .navigationTitle("Camera & Gallery")
    }
}
