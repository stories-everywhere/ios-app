//
//  ContentView.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var promptInputs: PromptInputs
    @State private var chosenImageUrl: URL?
    @StateObject private var storyGenerator = StoryGenerator()
    @State private var showQueue = false
    
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
                
                // Top control panel with generate button and status indicators
                ZStack{
                    Capsule()
                        .fill(.colorPayneGray)
                        .stroke(buttonRimmGradient, lineWidth: 3)
                        .frame(width: 280, height: 80)
                    
                    HStack(spacing: 15){
                        // Main generate/stop button
                        Button(action: {
                            if storyGenerator.isContinuousMode {
                                storyGenerator.stopContinuousGeneration()
                            } else {
                                promptInputs.initialisedWeather()
                                storyGenerator.weather = promptInputs.weather
                                storyGenerator.date = promptInputs.date
                                storyGenerator.generate()
                            }
                        }){
                            ZStack {
                                Circle()
                                    .fill(storyGenerator.isContinuousMode ? .red.opacity(0.8) : .colorFrenchGray)
                                    .stroke(buttonRimmGradient, lineWidth: 3)
                                    .frame(width: 60)
                                
                                Image(systemName: storyGenerator.isContinuousMode ? "stop.fill" : "iphone.gen3.badge.play")
                                    .fontWeight(.black)
                                    .foregroundStyle(.colorPayneGray)
                                    .font(.title)
                                    .imageScale(.large)
                            }.frame(width: 60)
                        }
                        
                        // Generation counter
                        if storyGenerator.isContinuousMode {
                            VStack(spacing: 2) {
                                Text("Stories")
                                    .font(.caption2)
                                    .foregroundColor(.colorFrenchGray)
                                    .fontWeight(.bold)
                                
                                Text("\(storyGenerator.generationCount)")
                                    .font(.title2)
                                    .foregroundColor(.colorPowderBlue)
                                    .fontWeight(.bold)
                            }
                            .frame(width: 50)
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
                
                // Continuous mode indicator
                if storyGenerator.isContinuousMode {
                    HStack {
                        Image(systemName: "infinity")
                            .foregroundColor(.colorPowderBlue)
                            .font(.caption)
                        
                        Text("Continuous Mode Active")
                            .font(.caption)
                            .foregroundColor(.colorPowderBlue)
                            .fontWeight(.semibold)
                        
                        // Processing indicator
                        if storyGenerator.isProcessing {
                            ProgressView()
                                .scaleEffect(0.5)
                                .tint(.colorPowderBlue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.colorPayneGray.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.top, 10)
                } else {
                    HStack {
//                        Image(systemName: "infinity")
//                            .foregroundColor(.colorPowderBlue)
//                            .font(.caption)
                        
                        Text("Continuous Mode Not Active")
                            .font(.caption)
                            .foregroundColor(.colorPowderBlue)
                            .fontWeight(.semibold)
                        
                        // Processing indicator
                        if storyGenerator.isProcessing {
                            ProgressView()
                                .scaleEffect(0.5)
                                .tint(.colorPowderBlue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.colorPayneGray.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.top, 10)
                }
                
                // Camera preview section
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
                                .colorMultiply(Color(.colorFrenchGray))
                                .opacity(0.5)
                            
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 50, bottomLeading: 20, bottomTrailing: 100, topTrailing: 30))
                                .stroke(buttonRimmGradient, lineWidth: 15)
                            
                            // Recording indicator overlay
                            if storyGenerator.isProcessing {
                                VStack {
                                    HStack {
                                        Spacer()
                                        HStack {
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 8, height: 8)
//                                                .opacity(recordingOpacity)
                                            
                                            Text("REC")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.black.opacity(0.7))
                                        .cornerRadius(8)
                                        .padding()
                                    }
                                    Spacer()
                                }
                            }
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
                
                // Audio progress bar (only show when audio is available)
//                if !storyGenerator.audioQueue.isEmpty || storyGenerator.isPlayingAudio {
                    VStack(spacing: 8) {
                        // Current playing title
                        if !storyGenerator.currentAudioTitle.isEmpty {
                            Text(storyGenerator.currentAudioTitle)
                                .font(.caption)
                                .foregroundColor(.colorFrenchGray)
                                .lineLimit(1)
                        }
                        
                        // Progress bar with custom styling
                        ZStack {
                            Capsule()
                                .fill(.colorPowderBlue)
                                .frame(height: 6)
                            
                            GeometryReader { geometry in
                                Capsule()
                                    .fill(.colorPayneGray)
                                    .frame(width: geometry.size.width * storyGenerator.audioProgress, height: 4)
                            }
                            .frame(height: 4)
                        }
                        .frame(width: audioControlWidth)
                        
                        // Time display
                        HStack {
                            Text(formatTime(storyGenerator.audioProgress * (storyGenerator.audioPlayer?.duration ?? 0)))
                                .font(.caption2)
                                .foregroundColor(.colorPrussianBlue)
                            
                            Spacer()
                            
                            Text(formatTime(storyGenerator.audioPlayer?.duration ?? 0))
                                .font(.caption2)
                                .foregroundColor(.colorPrussianBlue)
                                
                        }
                        .frame(width: audioControlWidth)
                    }
                    .padding(.bottom, 10)
//                }
                
                // Audio control panel
                ZStack{
                    Capsule()
                        .fill(.colorPayneGray)
                        .stroke(buttonRimmGradient, lineWidth: 3)
                        .frame(width: audioControlWidth, height: 80)
                    
                    
                    HStack(spacing: 15){
                        // Previous button (only show if queue has multiple items)
//                        if storyGenerator.audioQueue.count > 1 {
                            Button(action: {
                                Task {
                                    await storyGenerator.playPreviousInQueue()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.colorFrenchGray)
                                        .stroke(buttonRimmGradient, lineWidth: 3)
                                        .frame(width: 50)
                                    
                                    Image(systemName: "backward.fill")
                                        .fontWeight(.black)
                                        .foregroundStyle(storyGenerator.currentAudioIndex > 0 ? .colorPayneGray : .colorPayneGray.opacity(0.5))
                                        .font(.title2)
                                }.frame(width: 50)
                            }
                            .disabled(storyGenerator.currentAudioIndex <= 0)
//                        }
                        
                        // Play/Pause button
                        Button(action: {
                            if storyGenerator.audioQueue.isEmpty {
                                return
                            }
                            
                            if storyGenerator.currentAudioIndex == -1 {
                                Task {
                                    await storyGenerator.playNextInQueue()
                                }
                            } else {
                                storyGenerator.pauseResumeAudio()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.colorFrenchGray)
                                    .stroke(buttonRimmGradient, lineWidth: 3)
                                    .frame(width: 60)
                                
                                Image(systemName: storyGenerator.isPlayingAudio ? "pause.fill" : "play.fill")
                                    .fontWeight(.black)
                                    .foregroundStyle(storyGenerator.audioQueue.isEmpty ? .colorPayneGray.opacity(0.5) : .colorPayneGray)
                                    .font(.title)
                            }.frame(width: 60)
                        }
                        .disabled(storyGenerator.audioQueue.isEmpty)
                        
                        // Next/Forward button
                        Button(action: {
                            Task {
                                await storyGenerator.playNextInQueue()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.colorFrenchGray)
                                    .stroke(buttonRimmGradient, lineWidth: 3)
                                    .frame(width: 50)

                                Image(systemName: "forward.fill")
                                    .fontWeight(.black)
                                    .foregroundStyle(canPlayNext ? .colorPayneGray : .colorPayneGray.opacity(0.5))
                                    .font(.title2)
                            }.frame(width: 50)
                        }
                        .disabled(!canPlayNext)
                        
                        // Queue button (only show if there are items in queue)
//                        if !storyGenerator.audioQueue.isEmpty {
                            Button(action: {
                                showQueue = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.colorFrenchGray)
                                        .stroke(buttonRimmGradient, lineWidth: 3)
                                        .frame(width: 40)
                                    
                                    VStack(spacing: 2) {
                                        Image(systemName: "list.bullet")
                                            .fontWeight(.black)
                                            .foregroundStyle(.colorPayneGray)
                                            .font(.caption)
                                        
                                        Text("\(storyGenerator.audioQueue.count)")
                                            .fontWeight(.black)
                                            .foregroundStyle(.colorPayneGray)
                                            .font(.caption2)
                                    }
                                }.frame(width: 40)
                            }
//                        }
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
            
            // Status message overlay
            VStack(alignment: .leading){
                HStack {
                    Spacer()
                    
                    if !storyGenerator.statusMessage.isEmpty {
                        Text(storyGenerator.statusMessage)
                            .font(.headline)
                            .foregroundColor(.colorFrenchGray)
                            .padding(.bottom,4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.colorPayneGray.opacity(0.8))
                            .cornerRadius(20)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .background(backgroundGradient)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showQueue) {
            AudioQueueView(storyGenerator: storyGenerator)
        }
    }
    
    // Computed properties for cleaner code
    private var audioControlWidth: CGFloat {
        var width: CGFloat = 270 // Base width for play button
        
//        if storyGenerator.audioQueue.count > 1 {
//            width += 130 // Add space for prev/next buttons
//        } else {
//            width += 65 // Add space for just next button
//        }
//        
//        if !storyGenerator.audioQueue.isEmpty {
//            width += 55 // Add space for queue button
//        }
        
        return width
    }
    
    private var canPlayNext: Bool {
        return storyGenerator.currentAudioIndex < storyGenerator.audioQueue.count - 1 ||
               (!storyGenerator.audioQueue.isEmpty && storyGenerator.currentAudioIndex == -1)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Audio Queue View (styled to match your design)
struct AudioQueueView: View {
    @ObservedObject var storyGenerator: StoryGenerator
    @Environment(\.presentationMode) var presentationMode
    
    let buttonRimmGradient = AngularGradient(gradient: Gradient(colors: [.colorPayneGray, .colorPayneGray, .colorFrenchGray, .colorPayneGray, .colorFrenchGray, .colorPayneGray]), center: .center)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching your main view
                Color.colorPrussianBlue.ignoresSafeArea()
                
                VStack {
                    if storyGenerator.audioQueue.isEmpty {
                        Spacer()
                        Text("No audio in queue")
                            .foregroundColor(.colorFrenchGray)
                            .font(.headline)
                            .italic()
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(storyGenerator.audioQueue.enumerated()), id: \.element.id) { index, item in
                                AudioQueueRowView(
                                    item: item,
                                    index: index,
                                    isCurrentlyPlaying: index == storyGenerator.currentAudioIndex,
                                    storyGenerator: storyGenerator
                                )
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Audio Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.colorPayneGray, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarItems(
                leading: Button("Clear All") {
                    storyGenerator.clearAudioQueue()
                }
                .foregroundColor(.colorPowderBlue)
                .disabled(storyGenerator.audioQueue.isEmpty),
                
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.colorFrenchGray)
            )
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            storyGenerator.removeFromQueue(at: index)
        }
    }
}

struct AudioQueueRowView: View {
    let item: AudioQueueItem
    let index: Int
    let isCurrentlyPlaying: Bool
    @ObservedObject var storyGenerator: StoryGenerator
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Playing indicator
                    if isCurrentlyPlaying {
                        Image(systemName: storyGenerator.isPlayingAudio ? "speaker.wave.2.fill" : "pause.circle.fill")
                            .foregroundColor(.colorPowderBlue)
                            .font(.caption)
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(isCurrentlyPlaying ? .colorPowderBlue : .colorFrenchGray)
                }
                
                Text(item.storyText)
                    .font(.caption)
                    .foregroundColor(.colorFrenchGray.opacity(0.8))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            // Play button for non-current items
            if !isCurrentlyPlaying {
                Button(action: {
                    Task {
                        // Stop current audio and play this specific item
                        storyGenerator.stopAudio()
                        storyGenerator.currentAudioIndex = index - 1 // Will be incremented in playNextInQueue
                        await storyGenerator.playNextInQueue()
                    }
                }) {
                    Image(systemName: "play.circle")
                        .foregroundColor(.colorPowderBlue)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isCurrentlyPlaying ? Color.colorPowderBlue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
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
