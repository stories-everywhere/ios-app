//
//  PixelateShader.metal
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 12/06/2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 pixelateShader(VertexOut in [[stage_in]],
                                texture2d<float> texture [[texture(0)]],
                                sampler textureSampler [[sampler(0)]])
{
    float2 resolution = float2(160.0, 144.0); // 8-bit era resolution (e.g., Game Boy)
    float2 uv = floor(in.texCoord * resolution) / resolution;
    return texture.sample(textureSampler, uv);
}

vertex VertexOut vertex_passthrough(uint vertexID [[vertex_id]]) {
    float2 positions[6] = {
        float2(-1, -1), float2(1, -1), float2(-1, 1),
        float2(1, -1), float2(1, 1), float2(-1, 1)
    };

    float2 texCoords[6] = {
        float2(0, 1), float2(1, 1), float2(0, 0),
        float2(1, 1), float2(1, 0), float2(0, 0)
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0, 1);
    out.texCoord = texCoords[vertexID];
    return out;
}
