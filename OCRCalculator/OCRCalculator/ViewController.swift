//
//  ViewController.swift
//  OCRCalculator
//
//  Created by Samantha Gatt on 8/6/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Properties
    private let captureSession = AVCaptureSession()
    private lazy var cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private let overlayLayer = CALayer()
    private var sampleBuffer: CMSampleBuffer?
    
    // MARK: Instance methods
    private func presentAlertController() {
        let alertController = UIAlertController(title: "Uh Oh!", message: "Something unexpected happened. Please try again.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    private func setupAVSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        defer { captureSession.commitConfiguration() }
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera),
            captureSession.canAddInput(input) else {
                presentAlertController()
                return
        }
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(output) else {
            presentAlertController()
            return
        }
        captureSession.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "AV Output Queue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        cameraLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        view.layer.addSublayer(overlayLayer)
    }
}

// MARK: - AV Capture Video Data Output Sample Buffer Delegate
extension ViewController {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.sampleBuffer = sampleBuffer
    }
}
