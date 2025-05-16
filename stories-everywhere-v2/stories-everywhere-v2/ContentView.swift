//
//  ContentView.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var isCameraReady = false

    var body: some View {
        ZStack {
            CameraPreview(isCameraReady: $isCameraReady)
                .edgesIgnoringSafeArea(.all)
            
            if !isCameraReady {
                            Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                            ProgressView("Loading Camera...")
                                .foregroundColor(.white)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                VStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Text("Start Generation")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @Binding var isCameraReady:Bool
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        let session = AVCaptureSession()
        session.sessionPreset = .vga640x480 ///A preset suitable for capturing VGA quality (640 x 480 pixel) video output.
        
        DispatchQueue.global(qos: .userInitiated).async { ///userInitiated:The quality-of-service class for tasks that prevent the user from actively using your app.
            
            guard
                let device = AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input)
            else {
                return
            }
            
            session.addInput(input)
            DispatchQueue.main.async {
                view.videoPreviewLayer.session = session
                view.videoPreviewLayer.videoGravity = .resizeAspectFill
                DispatchQueue.global(qos: .background).async { session.startRunning() } ///[AVCaptureSession startRunning] should be called from background thread. Calling it on the main thread can lead to UI unresponsiveness
                isCameraReady = true
            }
        }
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}

#Preview {
    CameraView()
}
