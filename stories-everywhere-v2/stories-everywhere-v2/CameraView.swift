//
//  ContentView.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
//    @StateObject private var videoCapture = VideoCapture()
    @State private var chosenImageUrl: URL?
    @StateObject private var storyGenerator = StoryGenerator()
    
    var body: some View {
            ZStack {
                CameraPreview(videoCapture: storyGenerator.videoCapture)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    Button(action: {
//                        storyGenerator.videoCapture.startRecording()
                        storyGenerator.generate()
//                       let urlAvailable = try await  videoCapture.UrlIsAvailable
//                            guard let videoURL = videoCapture.recordedVideoURL else {
//                                print("No recorded video URL")
//                                return
//                            }
//                            
//                            storyGenerator.getFrames(from: videoURL)
//                        }
                    }) {
                        Text("start generation <3")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)

                    
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
