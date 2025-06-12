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
    let backgroundGradient = MeshGradient(
        width: 4,
        height: 4,
        points: [
            [0.0, 0.0], [0.3, 0.0], [0.7, 0.0], [1.0, 0.0],
            [0.0, 0.3], [0.7, 0.4], [0.2, 0.2], [1.0, 0.3],
            [0.0, 0.7], [0.3, 0.8], [0.7, 0.6], [1.0, 0.7],
            [0.0, 1.0], [0.3, 1.0], [0.7, 1.0], [1.0, 1.0]
        ],
        colors: [
            Color(white: 0.25), Color(white: 0.29), Color(white: 0.25), Color(white: 0.89),
            Color(white: 0.72), Color(white: 0.25), Color(white: 0.72), Color(white: 0.89),
            Color(white: 0.66), Color(white: 0.72), Color(white: 0.89), Color(white: 0.66),
            Color(white: 0.89), Color(white: 0.66), Color(white: 0.72), Color(white: 0.25)
        ]
    )

    
    let buttonGradient = MeshGradient(
        width: 2,
        height: 2,
        points: [
            [0, 0], [1, 0],
            [0, 1], [1, 1]
        ],
        colors: [
            .black, Color("darkslategrey"),
            Color("steelblue"), .white
        ]
    )
    
    let shadowGradient = RadialGradient(gradient: Gradient(colors: [.black, .black, .gray, .white, .white]), center: .center, startRadius: 50, endRadius: 100)
    let buttonRimmGradient = AngularGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .white, .black]), center: .center)

    var body: some View {
      
            ZStack {
                
                VStack {
                    //                    Spacer()
                    Spacer()
                    Spacer()
                    Button(action: {
                        storyGenerator.generate()
                        
                    }) {
                        //                        Text("start generation <3")
                        //                            .padding()
                        //                            .background(Color.white.opacity(0.8))
                        //                            .cornerRadius(10)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .white, .black]), center: .center)
                                )
                                .frame(width: 60)
                            Circle()
                                .fill(.black)
                                .frame(width: 40)
                            Image(systemName: "iphone.gen3.badge.play")
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                                .font(.title)
                            
                            //                            .cornerRadius(1000)
                        }.frame(width: 60)
                    }
                    .padding(.top, 40)
                    VStack{
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        HStack{
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            CameraPreview(videoCapture: storyGenerator.videoCapture)
                                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 50, bottomLeading: 20, bottomTrailing: 100, topTrailing: 30)))
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        
                    }
                    
                    ZStack{
                        Capsule()
                            .fill(.white)
                            .frame(width: 180, height: 80)
                        Capsule()
                            .fill(shadowGradient)
                            .frame(width: 180-10, height: 80-10)
                        
                        HStack{
                            
                            Button(action: {
                                storyGenerator.pauseResumeAudio()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            AngularGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .white, .black]), center: .center)
                                        )
                                        .frame(width: 60)
                                    Circle()
                                        .fill(.black)
                                        .frame(width: 40)
                                    
                                    Image(systemName: "playpause.fill")
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                        .font(.title)
                                }.frame(width: 60)
                            }
                            
                            Button(action: {
                                //forward
                                //                            storyGenerator.pauseResumeAudio()
                                
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            buttonRimmGradient
                                        )
                                        .frame(width: 60)
                                    Circle()
                                        .fill(.black)
                                        .frame(width: 40)
                                    Image(systemName: "forward.fill")
                                        .fontWeight(.black)
                                        .foregroundStyle(.white)
                                        .font(.title)
                                }.frame(width: 60)
                            }
                        }
                        
                        
                        
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                VStack(alignment: .leading){
                    
                    Text(storyGenerator.statusMessage)
                        .font(.headline)
                    
                }

            }
            .background(backgroundGradient)
            .edgesIgnoringSafeArea(.all)
            
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
