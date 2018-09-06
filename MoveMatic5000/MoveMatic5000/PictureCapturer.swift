//
//  PictureCapturer.swift
//  MoveMatic5000
//
//  Created by Raffaele La Brocca on 06/09/2018.
//  Copyright © 2018 Robert Wiltshire. All rights reserved.
//

import Cocoa
import AVFoundation

class PictureCapturer: NSObject {

    private let captureSession = AVCaptureSession()
    private var captureDevice : AVCaptureDevice?
    
    var lastCapturedImage: NSImage?
    
    func startCapture() {
        captureSession.sessionPreset = AVCaptureSession.Preset.low
        
        // Get all audio and video devices on this machine
        let devices = AVCaptureDevice.devices()
        
        // Find the FaceTime HD camera object
        for device in devices {
            // Camera object found and assign it to captureDevice
            if ((device as AnyObject).hasMediaType(AVMediaType.video)) {
                print("found camera: \(device)")
                captureDevice = device
            }
        }
        
        
        if captureDevice != nil {
            
            do {
                
                //setup output
                let output = AVCaptureVideoDataOutput()
                output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
                output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                captureSession.addOutput(output)
                
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
                
                // Start camera
                captureSession.startRunning()
                
            } catch {
                print(AVCaptureSessionErrorKey.description)
            }
        }
    }
        
}

extension PictureCapturer: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer)  {
            lastCapturedImage = outputImage
        }
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> NSImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = NSImage(cgImage: cgImage, size: NSSize(width: 300, height: 300))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
}
