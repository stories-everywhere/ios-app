//
//  ContentView.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var videoCapture = VideoCapture()
//    @State private var isCameraReady = true

    var body: some View {
            ZStack {
                CameraPreview(videoCapture: videoCapture)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    Button(action: {
                        videoCapture.startRecording()
                    }) {
                        Text("start generation <3")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)

                    if let url = videoCapture.recordedVideoURL {
                        Text("Saved to: \(url.lastPathComponent)")
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
}

struct CameraPreview: UIViewRepresentable {
    let videoCapture: VideoCapture

    class PreviewView: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
            previewLayer?.removeFromSuperlayer()
            previewLayer = layer
            self.layer.addSublayer(layer)
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        let layer = videoCapture.getPreviewLayer()
        view.setPreviewLayer(layer)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // No update needed
    }
}
#Preview {
    CameraView()
}
