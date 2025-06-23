//
//  PixelShaderView.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 12/06/2025.
//

import UIKit
import MetalKit

class PixelShaderView: MTKView {
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var texture: MTLTexture!

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
        loadTexture()
        createPipeline()
    }

    func loadTexture() {
        let textureLoader = MTKTextureLoader(device: device!)
        if let url = Bundle.main.url(forResource: "example", withExtension: "png") {
            texture = try? textureLoader.newTexture(URL: url, options: nil)
        }
    }

    func createPipeline() {
        let library = device!.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_passthrough")
        let fragmentFunction = library?.makeFunction(name: "pixelateShader")

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat

        pipelineState = try? device?.makeRenderPipelineState(descriptor: descriptor)
    }

    override func draw(_ rect: CGRect) {
        guard let drawable = currentDrawable,
              let descriptor = currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentTexture(texture, index: 0)

        // Add your vertex buffer and draw call here
        

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
