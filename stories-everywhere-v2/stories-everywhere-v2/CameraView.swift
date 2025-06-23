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
    @ObservedObject var promptInputs: PromptInputs
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
            Color(.colorPrussianBlue), Color(.colorPrussianBlue), Color(.colorPrussianBlue), Color(.colorFrenchGray),
            Color(.colorPowderBlue), Color(.colorPrussianBlue), Color(.colorPowderBlue), Color(.colorFrenchGray),
            Color(.colorPayneGray), Color(.colorPowderBlue), Color(.colorFrenchGray), Color(.colorPayneGray),
            Color(.colorFrenchGray), Color(.colorPayneGray), Color(.colorPowderBlue), Color(.colorPrussianBlue)
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
    let buttonRimmGradient = AngularGradient(gradient: Gradient(colors: [.colorPayneGray, .colorPayneGray, .colorFrenchGray, .colorPayneGray, .colorFrenchGray, .colorPayneGray]), center: .center)

    var body: some View {
      
            ZStack {
                
                VStack {
                    Spacer()
                    Spacer()
                    ZStack{
                        Capsule()
                            .fill(.colorPayneGray)
                            .stroke(buttonRimmGradient, lineWidth: 3)
                            .frame(width: 240, height: 80)
                        
                        HStack(spacing: 20){
                            
                            Button(action: {
                                promptInputs.initialisedWeather()
                                storyGenerator.weather = promptInputs.weather
                                storyGenerator.date = promptInputs.date
                                storyGenerator.generate()
                                
                            }){
                                ZStack {
                                    Circle()
                                        .fill(.colorFrenchGray)
                                        .stroke(buttonRimmGradient, lineWidth: 3)
                                        .frame(width: 60)
                                    Image(systemName: "iphone.gen3.badge.play")
                                        .fontWeight(.black)
                                        .foregroundStyle(.colorPayneGray)
                                        .font(.title)
                                        .imageScale(.large)
                                    
                                }.frame(width: 60)
                            }
                            //weather icons
                            VStack{
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud" )
                                    .fontWeight(.black)
                                    .foregroundStyle(.colorFrenchGray)
                                    .font(.title)
                                    .imageScale(.small)
                                    .frame(width: 10)
                                
                                
                                if(promptInputs.weatherLoading){
                                    ZStack{
                                        
                                        ProgressView()
                                            .tint(.colorPowderBlue)
                                    }
                                    .frame(width: 60)
                                } else{
                                    Image(systemName: promptInputs.weatherIcon )
                                        .fontWeight(.black)
                                        .foregroundStyle(.colorFrenchGray)
                                        .font(.title)
                                        .imageScale(.medium)
                                        .frame(width: 60)
                                }
                            }
                            
                            //location icons
                            VStack{
                                Image(systemName: "location.magnifyingglass" )
                                    .fontWeight(.black)
                                    .foregroundStyle(.colorFrenchGray)
                                    .font(.title)
                                    .imageScale(.small)
                                    .frame(width: 10)
                                
                                
                                if(promptInputs.locationLoading){
                                    ZStack{
                                        
                                        ProgressView()
                                            .tint(.colorPowderBlue)
                                    }
                                    .frame(width: 60)
                                } else{
                                    Image(systemName: "location" )
                                        .fontWeight(.black)
                                        .foregroundStyle(.colorFrenchGray)
                                        .font(.title)
                                        .imageScale(.medium)
                                        .frame(width: 60)
                                }
                            }
                        }
                    }
                    .padding(.top, 60)
                    
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
                            ZStack{
                                CameraPreview(videoCapture: storyGenerator.videoCapture)
                                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 50, bottomLeading: 20, bottomTrailing: 100, topTrailing: 30)))
                                    .colorMultiply(Color(.colorDarkSlateGray)).opacity(0.5)
                                
                                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 50, bottomLeading: 20, bottomTrailing: 100, topTrailing: 30))
                                    .stroke(buttonRimmGradient, lineWidth: 15)
                                    
                            }
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
                            .fill(.colorPayneGray)
                            .stroke(buttonRimmGradient, lineWidth: 3)
                            .frame(width: 180, height: 80)
                        
                        HStack(spacing: 20){
                            
                            Button(action: {
                                storyGenerator.pauseResumeAudio()
                            }) {
                                ZStack {
                                   
                                    Circle()
                                        .fill(.colorFrenchGray)
                                        .stroke(buttonRimmGradient, lineWidth: 3)
                                        .frame(width: 60)
                                    
                                    Image(systemName: "playpause.fill")
                                        .fontWeight(.black)
                                        .foregroundStyle(.colorPayneGray)
                                        .font(.title)
                                }.frame(width: 60)
                            }
                            
                            Button(action: {
                                //forward
                                //                            storyGenerator.pauseResumeAudio()
                                
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.colorFrenchGray)
                                        .stroke(buttonRimmGradient, lineWidth: 3)
                                        .frame(width: 60)

                                    Image(systemName: "forward.fill")
                                        .fontWeight(.black)
                                        .foregroundStyle(.colorPayneGray)
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
//#Preview {
//    CameraView(promptInputs: promptInputs)
//}
