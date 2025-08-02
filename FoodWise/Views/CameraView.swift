//
//  CameraView.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let previewLayer = cameraManager.setupCamera() {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            cameraManager.startSession()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraViewScreen: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss
    @Binding var capturedImage: UIImage?
    @Binding var detectedBarcode: String?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.capturePhoto()
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 60, height: 40)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: cameraManager.capturedImage) { image in
            if let image = image {
                capturedImage = image
                detectedBarcode = cameraManager.detectedBarcode
                dismiss()
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}
