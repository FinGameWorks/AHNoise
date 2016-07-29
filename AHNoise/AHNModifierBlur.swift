//
//  AHNModifierBlur.swift
//  AHNoise
//
//  Created by Andrew Heard on 19/05/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import Metal
import simd
import MetalPerformanceShaders


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and blurs its texture.
 
 The input undergoes a Gaussian blur with a specified `radius`. Note that this is computationally expensive for larger radii.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierBlur: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///The radius of the Gaussian blur. The default value is `3.0`.
  public var radius: Float = 3{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The `Metal Performance Shader` used to perform the blur.
  var kernel: MPSImageGaussianBlur!
  
  
  


  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "normalMapModifier")
    usesMPS = true
    kernel = MPSImageGaussianBlur(device: context.device, sigma: radius)
    kernel.edgeMode = .Clamp
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the `Metal Performance Shader` into the command buffer. This is called by the superclass and should not be called manually.
  override public func addMetalPerformanceShaderToBuffer(commandBuffer: MTLCommandBuffer) {
    guard let texture = provider?.texture() else { return }
    kernel = MPSImageGaussianBlur(device: context.device, sigma: radius)
    kernel.edgeMode = .Clamp
    kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: texture, destinationTexture: internalTexture!)
  }
}
