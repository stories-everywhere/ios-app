//
//  VideoCapture.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import AVFoundation

class VideoCapture: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var isRecording = false

    @Published var recordedVideoURL: URL? = nil
    
    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            print("Failed to set video input")
            return
        }
        session.addInput(videoInput)

        

        // Add movie output
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        session.commitConfiguration()
        DispatchQueue.global(qos: .background).async { self.session.startRunning() }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        if !session.isRunning {
            session.startRunning()
        }
        return previewLayer
    }

    func startRecording() {
        guard !isRecording else { return }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: tempURL) // remove old if exists

        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true

        // Stop recording after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopRecording()
        }
    }

    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }
}

extension VideoCapture: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                        didFinishRecordingTo outputFileURL: URL,
                        from connections: [AVCaptureConnection],
                        error: Error?) {
            isRecording = false
            if let error = error {
                print("Recording error: \(error.localizedDescription)")
            } else {
                print("Video saved to: \(outputFileURL)")
                DispatchQueue.main.async {
                    self.recordedVideoURL = outputFileURL
                }
            }
        }
}
