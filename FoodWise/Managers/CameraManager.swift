//
//  CameraManager.swift
//  FoodWise
//
//  Created by Aditya Makhija on 2025-08-02.
//

import Foundation
import AVFoundation
import UIKit
import Vision
import VisionKit

class CameraManager: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var detectedBarcode: String?
    @Published var isShowingCamera = false
    
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupCamera() -> AVCaptureVideoPreviewLayer? {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return nil }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return nil
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return nil
        }
        
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        } else {
            return nil
        }
        
        self.captureSession = session
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        
        return previewLayer
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func detectBarcode(in image: UIImage, completion: @escaping (String?) -> Void) {
        print("🔍 Starting barcode detection on image...")
        
        guard let cgImage = image.cgImage else {
            print("❌ Failed to get CGImage from UIImage")
            completion(nil)
            return
        }
        
        print("📸 Image size: \(cgImage.width) x \(cgImage.height)")
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("❌ Barcode detection error: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNBarcodeObservation] else {
                print("⚠️ No barcode observations found")
                completion(nil)
                return
            }
            
            print("📊 Found \(observations.count) barcode observation(s)")
            
            for (index, observation) in observations.enumerated() {
                print("🔎 Barcode \(index + 1): Type: \(observation.symbology.rawValue), Confidence: \(observation.confidence)")
                if let payload = observation.payloadStringValue {
                    print("📱 Barcode \(index + 1) payload: \(payload)")
                }
            }
            
            guard let firstBarcode = observations.first,
                  let barcodeValue = firstBarcode.payloadStringValue else {
                print("❌ No valid barcode payload found")
                completion(nil)
                return
            }
            
            print("✅ Successfully detected barcode: \(barcodeValue)")
            completion(barcodeValue)
        }
        
        // Configure supported barcode types
        request.symbologies = [
            .ean13, .ean8, .upce, .code128, // Common grocery barcodes
            .qr, .code39, .code93, // Other common types
            .pdf417, .dataMatrix, .aztec // Additional types
        ]
        
        print("🎯 Configured barcode symbologies: \(request.symbologies.map { $0.rawValue })")
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("❌ Failed to perform barcode detection: \(error)")
            completion(nil)
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { 
            print("❌ Failed to convert photo to UIImage")
            return 
        }
        
        print("📸 Photo captured successfully - Size: \(image.size)")
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.stopSession()
        }
        
        // Check for barcode
        print("🔍 Starting barcode detection on captured photo...")
        detectBarcode(in: image) { [weak self] barcode in
            DispatchQueue.main.async {
                if let barcode = barcode {
                    print("✅ Barcode detected in photo: \(barcode)")
                } else {
                    print("ℹ️ No barcode detected in photo - will use image analysis")
                }
                self?.detectedBarcode = barcode
            }
        }
    }
}
