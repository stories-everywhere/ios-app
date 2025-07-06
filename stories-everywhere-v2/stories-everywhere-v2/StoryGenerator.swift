//
//  StoryGeneration.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUICore
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Audio Queue Item
struct AudioQueueItem: Identifiable {
    let id = UUID()
    let data: Data
    let title: String
    let storyText: String
}

class StoryGenerator: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var chosenFrameURL: URL? = nil
    @Published var isProcessing: Bool = false
    @Published var error: Error? = nil
    @Published var videoCapture = VideoCapture()
    @Published var statusMessage: String = ""
    @Published var storyResponse: StoryResponse? = nil
    @Published var story: String = ""
    @Published var isPlayingAudio: Bool = false
    @Published var audioProgress: Double = 0.0
    @Published var audioQueue: [AudioQueueItem] = []
    @Published var currentAudioIndex: Int = -1
    @Published var currentAudioTitle: String = ""
    @Published var isContinuousMode: Bool = false
    @Published var generationCount: Int = 0
    
    var weather: String = "unrecognisable weather"
    var date: String = "unkown date"
    
    // MARK: - Audio Properties
    public var audioPlayer: AVAudioPlayer?
    private var audioTimer: Timer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Continuous Generation Properties
    private var continuousGenerationTimer: Timer?
    private let generationInterval: TimeInterval = 30.0 // Generate every 30 seconds
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        audioTimer?.invalidate()
        audioPlayer?.stop()
        stopContinuousGeneration()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Continuous Generation Control
    func startContinuousGeneration() {
        guard !isContinuousMode else { return }
        
        isContinuousMode = true
        generationCount = 0
        
        // Start first generation immediately
        generateStory()
        
        // Set up timer for subsequent generations
        continuousGenerationTimer = Timer.scheduledTimer(withTimeInterval: generationInterval, repeats: true) { _ in
            self.generateStory()
        }
        
        statusMessage = "Continuous generation started"
        print("Started continuous generation mode")
    }
    
    func stopContinuousGeneration() {
        guard isContinuousMode else { return }
        
        isContinuousMode = false
        continuousGenerationTimer?.invalidate()
        continuousGenerationTimer = nil
        
        statusMessage = "Continuous generation stopped"
        print("Stopped continuous generation mode")
    }
    
    func toggleContinuousGeneration() {
        if isContinuousMode {
            stopContinuousGeneration()
        } else {
            startContinuousGeneration()
        }
    }
    
    // MARK: - Generation Handling
    func generate(){
        // This is the original single generation method
        // Now it starts continuous mode
        startContinuousGeneration()
    }
    
    private func generateStory() {
        // Don't start new generation if we're already processing one
        // This prevents overlapping generations
        guard !isProcessing else {
            print("Generation already in progress, skipping this cycle")
            return
        }
        
        generationCount += 1
        isProcessing = true
        error = nil
        chosenFrameURL = nil
        
        let semaphore = DispatchSemaphore(value: 0)
        var finalVideoURL: URL? = nil
        
        videoCapture.onRecordingFinished = { url in
            finalVideoURL = url
            semaphore.signal()
        }
        
        videoCapture.startRecording()
        print("Started recording #\(generationCount), waiting synchronously...")
        
        DispatchQueue.main.async {
            self.statusMessage = "Recording story #\(self.generationCount)..."
        }
        
        // Wait (on background thread) until recording finishes
        DispatchQueue.global(qos: .userInitiated).async {
            let timeout = DispatchTime.now() + 30  // optional timeout (avoids infinite wait)
            if semaphore.wait(timeout: timeout) == .success {
                if let url = finalVideoURL {
                    print("Recording complete, extracting frames from: \(url)")
                    DispatchQueue.main.async {
                        self.statusMessage = "Extracting frames #\(self.generationCount)..."
                    }
                    self.getFrames(from: url)
                    
                } else {
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.error = NSError(domain: "VideoCapture", code: 4, userInfo: [NSLocalizedDescriptionKey: "Recording finished but no URL returned"])
                        self.statusMessage = "Recording failed #\(self.generationCount)"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.error = NSError(domain: "VideoCapture", code: 5, userInfo: [NSLocalizedDescriptionKey: "Recording timed out"])
                    self.statusMessage = "Recording timed out #\(self.generationCount)"
                }
            }
        }
    }
    
    // MARK: - Public API and find frame
//    func getFrames(from videoURL: URL) {
//        saveAllFramesFromVideo(url: videoURL) { urls, error in
//            DispatchQueue.main.async {
//                print("getting frames for generation #\(self.generationCount)")
//                
//                if let error = error {
//                    self.error = error
//                    self.isProcessing = false
//                    self.statusMessage = "Frame extraction failed #\(self.generationCount)"
//                    return
//                }
//                
//                if let urls = urls {
////                    self.chosenFrameURL = first
////                    print("chosen frame for generation #\(self.generationCount):", self.chosenFrameURL!)
//                    
//                    self.findLeastBlurryFrame(from: urls) { bestFrameURL in
//                                        if let bestFrame = bestFrameURL {
//                                            self.chosenFrameURL = bestFrame
//                                            print("Selected frame with best sharpness score")
//                                        } else {
//                                            // Fallback to first frame if analysis fails
//                                            self.chosenFrameURL = urls.first
//                                            print("Fallback to first frame")
//                                        }
//                                    }
//                    
//                    DispatchQueue.main.async {
//                        self.statusMessage = "Generating story #\(self.generationCount)..."
//                    }
//                    
//                    Task {
//                        do {
//                            self.storyResponse = try await self.requestStory(image: Data(contentsOf: self.chosenFrameURL!), weather: self.weather, date: self.date)
//                            
//                            DispatchQueue.main.async {
//                                self.statusMessage = "Story #\(self.generationCount) completed!"
//                                self.story = self.storyResponse?.text ?? ""
//                                self.isProcessing = false
//                            }
//                            
//                            // Add audio to queue instead of playing immediately
//                            await self.addStoryAudioToQueue()
//                        } catch {
//                            DispatchQueue.main.async {
//                                self.error = error
//                                self.isProcessing = false
//                                self.statusMessage = "Story generation failed #\(self.generationCount): \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                    
//                } else {
//                    self.error = NSError(
//                        domain: "VideoProcessor",
//                        code: 1,
//                        userInfo: [NSLocalizedDescriptionKey: "No frames extracted"]
//                    )
//                    self.isProcessing = false
//                    self.statusMessage = "No frames found #\(self.generationCount)"
//                }
//            }
//        }
//    }
    
    
    func getFrames(from videoURL: URL) {
        saveAllFramesFromVideo(url: videoURL) { urls, error in
            DispatchQueue.main.async {
                print("getting frames for generation #\(self.generationCount)")
                
                if let error = error {
                    self.error = error
                    self.isProcessing = false
                    self.statusMessage = "Frame extraction failed #\(self.generationCount)"
                    return
                }
                
                if let urls = urls {
                    self.statusMessage = "Analyzing frame quality #\(self.generationCount)..."
                    
                    self.findLeastBlurryFrame(from: urls) { bestFrameURL in
                        DispatchQueue.main.async {
                            if let bestFrame = bestFrameURL {
                                self.chosenFrameURL = bestFrame
                                print("Selected frame with best sharpness score for generation #\(self.generationCount)")
                            } else {
                                // Fallback to first frame if analysis fails
                                self.chosenFrameURL = urls.first
                                print("Fallback to first frame for generation #\(self.generationCount)")
                            }
                            
                            // Now that we have a chosen frame, proceed with story generation
                            guard let chosenFrame = self.chosenFrameURL else {
                                self.error = NSError(
                                    domain: "VideoProcessor",
                                    code: 3,
                                    userInfo: [NSLocalizedDescriptionKey: "No frame could be selected"]
                                )
                                self.isProcessing = false
                                self.statusMessage = "Frame selection failed #\(self.generationCount)"
                                return
                            }
                            
                            self.statusMessage = "Generating story #\(self.generationCount)..."
                            
                            Task {
                                do {
                                    let imageData = try Data(contentsOf: chosenFrame)
                                    self.storyResponse = try await self.requestStory(
                                        image: imageData,
                                        weather: self.weather,
                                        date: self.date
                                    )
                                    
                                    DispatchQueue.main.async {
                                        self.statusMessage = "Story #\(self.generationCount) completed!"
                                        self.story = self.storyResponse?.text ?? ""
                                        self.isProcessing = false
                                    }
                                    
                                    // Add audio to queue instead of playing immediately
                                    await self.addStoryAudioToQueue()
                                } catch {
                                    DispatchQueue.main.async {
                                        self.error = error
                                        self.isProcessing = false
                                        self.statusMessage = "Story generation failed #\(self.generationCount): \(error.localizedDescription)"
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    self.error = NSError(
                        domain: "VideoProcessor",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "No frames extracted"]
                    )
                    self.isProcessing = false
                    self.statusMessage = "No frames found #\(self.generationCount)"
                }
            }
        }
    }
    //MARK: - Least blurry frame detection
    
    
    func findLeastBlurryFrame(from urls: [URL], completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var bestFrameURL: URL?
            var highestSharpness: Double = 0.0
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "blur.analysis", attributes: .concurrent)
            let semaphore = DispatchSemaphore(value: 4) // Limit concurrent operations
            
            for url in urls {
                group.enter()
                semaphore.wait()
                
                queue.async {
                    defer {
                        semaphore.signal()
                        group.leave()
                    }
                    
                    if let sharpness = self.calculateSharpness(for: url) {
                        DispatchQueue.main.sync {
                            if sharpness > highestSharpness {
                                highestSharpness = sharpness
                                bestFrameURL = url
                            }
                        }
                        print("Frame \(url.lastPathComponent): sharpness = \(sharpness)")
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(bestFrameURL)
            }
        }
    }

    func calculateSharpness(for imageURL: URL) -> Double? {
        guard let image = UIImage(contentsOfFile: imageURL.path),
              let cgImage = image.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // Convert to grayscale for better performance
        let grayscaleFilter = CIFilter.colorMonochrome()
        grayscaleFilter.inputImage = ciImage
        grayscaleFilter.color = CIColor.white
        grayscaleFilter.intensity = 1.0
        
        guard let grayscaleImage = grayscaleFilter.outputImage else { return nil }
        
        // Apply Laplacian filter to detect edges
        let laplacianFilter = CIFilter.convolution3X3()
        laplacianFilter.inputImage = grayscaleImage
        laplacianFilter.weights = CIVector(values: [0, -1, 0, -1, 4, -1, 0, -1, 0], count: 9)
        laplacianFilter.bias = 0
        
        guard let outputImage = laplacianFilter.outputImage else { return nil }
        
        // Calculate variance of the Laplacian
        let extent = outputImage.extent
        guard let cgOutputImage = context.createCGImage(outputImage, from: extent) else { return nil }
        
        return calculateVariance(from: cgOutputImage)
    }

    func calculateVariance(from cgImage: CGImage) -> Double? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Calculate variance of pixel intensities
        var sum: Double = 0
        var sumSquared: Double = 0
        let totalPixels = width * height
        
        for i in stride(from: 0, to: totalBytes, by: bytesPerPixel) {
            // Use grayscale value (average of RGB)
            let r = Double(pixelData[i])
            let g = Double(pixelData[i + 1])
            let b = Double(pixelData[i + 2])
            let intensity = (r + g + b) / 3.0
            
            sum += intensity
            sumSquared += intensity * intensity
        }
        
        let mean = sum / Double(totalPixels)
        let variance = (sumSquared / Double(totalPixels)) - (mean * mean)
        
        return variance
    }

    // Alternative, simpler blur detection method using built-in filters
    func calculateSharpnessSimple(for imageURL: URL) -> Double? {
        guard let image = UIImage(contentsOfFile: imageURL.path),
              let cgImage = image.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // Use built-in edge detection
        let edgeFilter = CIFilter(name: "CIEdges")!
        edgeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        edgeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let outputImage = edgeFilter.outputImage else { return nil }
        
        // Calculate average pixel intensity of edge-detected image
        let extent = outputImage.extent
        guard let cgOutputImage = context.createCGImage(outputImage, from: extent) else { return nil }
        
        return calculateAverageIntensity(from: cgOutputImage)
    }

    func calculateAverageIntensity(from cgImage: CGImage) -> Double? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalIntensity: Double = 0
        let totalPixels = width * height
        
        for i in stride(from: 0, to: totalBytes, by: bytesPerPixel) {
            let r = Double(pixelData[i])
            let g = Double(pixelData[i + 1])
            let b = Double(pixelData[i + 2])
            totalIntensity += (r + g + b) / 3.0
        }
        
        return totalIntensity / Double(totalPixels)
    }
    // MARK: - Frame Extraction Logic
    private func saveAllFramesFromVideo(url: URL, completion: @escaping ([URL]?, Error?) -> Void) {
        let asset = AVURLAsset(url: url)
        
        // Load tracks asynchronously
        asset.loadTracks(withMediaType: .video) { tracks, error in
            guard let videoTrack = tracks?.first else {
                completion(nil, error ?? NSError(domain: "VideoProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "No video track found"]))
                return
            }
            
            do {
                let reader = try AVAssetReader(asset: asset)
                let outputSettings: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                let trackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
                reader.add(trackOutput)
                
                guard reader.startReading() else {
                    completion(nil, reader.error)
                    return
                }
                
                var frameURLs = [URL]()
                let context = CIContext()
                let tempDirectory = FileManager.default.temporaryDirectory
                var frameCount = 0
                
                while reader.status == .reading {
                    if let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                       let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                            let uiImage = UIImage(cgImage: cgImage)
                            let filename = "frame_\(frameCount).png"
                            let fileURL = tempDirectory.appendingPathComponent(filename)
                            if let data = uiImage.pngData() {
                                try? data.write(to: fileURL)
                                frameURLs.append(fileURL)
                                frameCount += 1
                            }
                        }
                        CMSampleBufferInvalidate(sampleBuffer)
                    }
                }
                
                if reader.status == .completed {
                    completion(frameURLs, nil)
                } else {
                    completion(nil, reader.error)
                }
                
            } catch {
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Audio Queue Management
    @MainActor
    func addStoryAudioToQueue() async {
        guard let storyResponse = storyResponse,
              !storyResponse.audioFiles.isEmpty else {
            print("No audio files available")
            return
        }
        
        // Add all audio files to queue
        for (index, base64Audio) in storyResponse.audioFiles.enumerated() {
            do {
                let audioData = try decodeBase64Audio(base64Audio)
                let title = "Story \(generationCount)" + (storyResponse.audioFiles.count > 1 ? " - Part \(index + 1)" : "")
                let queueItem = AudioQueueItem(
                    data: audioData,
                    title: title,
                    storyText: storyResponse.text
                )
                audioQueue.append(queueItem)
                print("Added audio to queue: \(title)")
            } catch {
                print("Error decoding audio \(index): \(error)")
            }
        }
        
        // Start playing if nothing is currently playing
        if !isPlayingAudio && !audioQueue.isEmpty && currentAudioIndex == -1 {
            await playNextInQueue()
        }
    }
    
    @MainActor
    func playNextInQueue() async {
        guard !audioQueue.isEmpty else {
            print("Audio queue is empty")
            return
        }
        
        // Stop current playback
        stopAudio()
        
        // Move to next item or start from beginning
        if currentAudioIndex < audioQueue.count - 1 {
            currentAudioIndex += 1
        } else if currentAudioIndex == -1 {
            currentAudioIndex = 0
        } else {
            // Reached end of queue
            currentAudioIndex = -1
            statusMessage = "Playback queue completed"
            return
        }
        
        let currentItem = audioQueue[currentAudioIndex]
        currentAudioTitle = currentItem.title
        
        do {
            try await playAudio(from: currentItem.data)
            statusMessage = "Playing: \(currentItem.title)"
        } catch {
            print("Error playing audio: \(error)")
            self.error = error
            // Try next item in queue
            await playNextInQueue()
        }
    }
    
    @MainActor
    func playPreviousInQueue() async {
        guard !audioQueue.isEmpty && currentAudioIndex > 0 else {
            print("Cannot go to previous item")
            return
        }
        
        currentAudioIndex -= 1
        let currentItem = audioQueue[currentAudioIndex]
        currentAudioTitle = currentItem.title
        
        // Stop current playback
        stopAudio()
        
        do {
            try await playAudio(from: currentItem.data)
            statusMessage = "Playing: \(currentItem.title)"
        } catch {
            print("Error playing audio: \(error)")
            self.error = error
        }
    }
    
    func clearAudioQueue() {
        stopAudio()
        audioQueue.removeAll()
        currentAudioIndex = -1
        currentAudioTitle = ""
        statusMessage = "Audio queue cleared"
    }
    
    func removeFromQueue(at index: Int) {
        guard index >= 0 && index < audioQueue.count else { return }
        
        // If removing currently playing item
        if index == currentAudioIndex {
            Task {
                await playNextInQueue()
            }
        } else if index < currentAudioIndex {
            // Adjust current index if we're removing an item before it
            currentAudioIndex -= 1
        }
        
        audioQueue.remove(at: index)
    }
    
    // MARK: - Audio Playback
    private func decodeBase64Audio(_ base64String: String) throws -> Data {
        guard let audioData = Data(base64Encoded: base64String) else {
            throw NSError(domain: "AudioDecoding", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 audio"])
        }
        return audioData
    }
    
    private func playAudio(from data: Data) async throws {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            await MainActor.run {
                self.isPlayingAudio = true
                self.audioProgress = 0.0
            }
            
            audioPlayer?.play()
            startAudioProgressTimer()
            
        } catch {
            await MainActor.run {
                self.isPlayingAudio = false
                self.error = error
            }
            throw error
        }
    }
    
    func stopAudio() {
        audioTimer?.invalidate()
        audioTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        
        DispatchQueue.main.async {
            self.isPlayingAudio = false
            self.audioProgress = 0.0
        }
    }
    
    func pauseResumeAudio() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            audioTimer?.invalidate()
            audioTimer = nil
            DispatchQueue.main.async {
                self.isPlayingAudio = false
            }
        } else {
            player.play()
            startAudioProgressTimer()
            DispatchQueue.main.async {
                self.isPlayingAudio = true
            }
        }
    }
    
    private func startAudioProgressTimer() {
        audioTimer?.invalidate()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                if let player = self.audioPlayer, player.isPlaying {
                    self.audioProgress = player.currentTime / player.duration
                } else {
                    self.audioTimer?.invalidate()
                    self.audioTimer = nil
                }
            }
        }
    }
    
    // MARK: - Story Generation
    struct StoryRequest {
        let image: Data
        let weather: String
        let length: Int
        let voice: String
    }
    
    struct StoryResponse: Decodable {
        let audioFiles: [String]
        let text: String
        let event: String
        let processingTime: String
        
        enum CodingKeys: String, CodingKey {
            case audioFiles = "audio_files"
            case text
            case event
            case processingTime = "processing_time"
        }
    }
    
    //date and voice are not being used in the generation yet
    func requestStory(image: Data, weather: String = "foggy",date: String =  "unkown date", length: Int = 200, voice: String = "af_heart") async throws -> StoryResponse {
        var components = URLComponents(string: "https://langate-story-api.onrender.com/generate-story")!
        components.queryItems = [
            URLQueryItem(name: "weather", value: weather),
            URLQueryItem(name: "length", value: "\(length)"),
            URLQueryItem(name: "voice", value: voice)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0 // Increase timeout for audio generation
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug response
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status: \(httpResponse.statusCode)")
        }
        
        let story = try JSONDecoder().decode(StoryResponse.self, from: data)
        
        // Debug log
        print("Received story:", story.text)
        print("Audio files count:", story.audioFiles.count)
        return story
    }
}

// MARK: - AVAudioPlayerDelegate
extension StoryGenerator: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlayingAudio = false
            self.audioProgress = flag ? 1.0 : 0.0
            self.audioTimer?.invalidate()
            self.audioTimer = nil
            
            if flag {
                // Automatically play next item in queue
                Task {
                    await self.playNextInQueue()
                }
            } else {
                self.statusMessage = "Audio playback failed"
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlayingAudio = false
            self.audioProgress = 0.0
            self.audioTimer?.invalidate()
            self.audioTimer = nil
            self.error = error
            self.statusMessage = "Audio decode error: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}
