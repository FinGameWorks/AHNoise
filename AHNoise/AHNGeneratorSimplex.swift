//
//  AHNSimplex3DGenerator.swift
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///Generates standard Simplex Noise. The noise created lies within the range `0.0 - 1.0`.
///
///*Conforms to the `AHNTextureProvider` protocol.*
public class AHNGeneratorSimplex: AHNGeneratorCoherent {
  
  
  // MARK:- Initialiser
    
  
  required public init(){
    super.init(functionName: "simplexGenerator")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = CoherentInputs(pos: vector_float2(xValue, yValue), rotations: vector_float3(xRotation, yRotation, zRotation), octaves: Int32(octaves), persistance: persistance, frequency: frequency, lacunarity: lacunarity,  zValue: zValue, wValue: wValue, offsetStrength: offsetStrength, use4D: Int32(use4D || seamless || sphereMap ? 1 : 0), sphereMap: Int32(sphereMap ? 1 : 0), seamless: Int32(seamless ? 1 : 0))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(CoherentInputs), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(CoherentInputs))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}