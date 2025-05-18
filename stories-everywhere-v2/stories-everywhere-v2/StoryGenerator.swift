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

class StoryGenerator: ObservableObject {
    // MARK: - Published Properties
        @Published var chosenFrameURL: URL? = nil
        @Published var isProcessing: Bool = false
        @Published var error: Error? = nil
        @Published var videoCapture = VideoCapture()
    
    func generate(){
        videoCapture.startRecording()
        print("start waiting")
        self.waitURl()
        
        print("end generate")
           
        
    }
    func waitURl(){
        if !videoCapture.UrlIsAvailable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.waitURl()
                print("waiting")
            }
        }  else{
            guard let url =  videoCapture.recordedVideoURL else {
                print("no url")
                return
            }
            print("Getting frames from: \(url)")
            self.getFrames(from: url )
            print("Generating")
            return
        }
        
    }
        // MARK: - Public API
        func getFrames(from videoURL: URL) {
            isProcessing = true
            error = nil
//            chosenFrameURL = nil

            saveAllFramesFromVideo(url: videoURL) { urls, error in
                DispatchQueue.main.async {
                    print("getting frames1")

                    self.isProcessing = false

                    if let error = error {
                        self.error = error
                        return
                    }

                    if let urls = urls, let first = urls.first {
                        self.chosenFrameURL = first
                        print("chosen frame:",self.chosenFrameURL!)
                    } else {
                        self.error = NSError(
                            domain: "VideoProcessor",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "No frames extracted"]
                        )
                    }
                }
            }
            
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
}

    
