//
//  AHNSimplex3DGenerator.swift
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///Generates standard Simplex Noise. The noise created lies within the range -1.0 - 1.0 numerically [0.0-1.0 in colour space].
///
///*Conforms to the `AHNTextureProvider` protocol.*
public class AHNGeneratorSimplex: AHNGenerator {
  
  
  // MARK:- Initialiser
  
  /**
   Creates a new `AHNGeneratorSimplex` object.
   - parameter context: The `AHNContext` object that will be used to create the buffers and command encoders required.
   - parameter textureWidth: The desired width of the output texture in pixels.
   - parameter textureHeight: The desired height of the output texture in pixels.
   - parameter use4DNoise: Switches the kernel to use 4D Simplex noise instead of 3D. Useful for when an extra dimension is required, for example to create volumetric noise or seamless noise. Has a higher resource requirement.
   - parameter mapForSphere: Toggles whether to map the output texture to wrap suitably onto a UV sphere geometry. Implicitly uses 4D noise and is seamless.
   - parameter makeSeamless: Toggles whether to make the texture seamless. The output will be tileable seamlessly with no mirroring. Implicitly uses 4D noise.
  */
  public init(context: AHNContext, textureWidth width: Int, textureHeight height: Int, use4DNoise: Bool, mapForSphere: Bool, makeSeamless: Bool){
    super.init(functionName: "simplexGenerator", context: context, textureWidth: width, textureHeight: height, use4DNoise: use4DNoise, mapForSphere: mapForSphere, makeSeamless: makeSeamless)
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = SimplexInputs(pos: vector_float2(position.x, position.y), octaves: Int32(octaves), persistance: persistance, frequency: frequency, lacunarity: lacunarity,  zValue: zValue, wValue: wValue, use4D: Int32(use4D), sphereMap: Int32(sphereMap), seamless: seamless)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(SimplexInputs), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(SimplexInputs))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}
