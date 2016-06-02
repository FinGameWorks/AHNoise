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
  
  
  ///The radius of the Gaussian blur.
  private var _radius: Float = 3
  
  
  
  ///The `Metal Performance Shader` used to perform the blur.
  private var kernel: MPSImageGaussianBlur!
  
  
  
  ///The radius of the Gaussian blur. Higher values are computationally expensive.
  public var radius: Float{
    get{
      return _radius
    }
    set{
      _radius = newValue
      dirty = true
    }
  }

  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  
  /**
   Creates a new `AHNModifierBlur` object.
   
   - parameter input: The input to blur.
   - parameter radius: The radius of the Gaussian blur.
   */
  public init(input: AHNTextureProvider, radius: Float){
    _radius = radius
    super.init(functionName: "loopModifier", input: input)
    usesMPS = true
    kernel = MPSImageGaussianBlur(device: context.device, sigma: _radius)
    kernel.edgeMode = .Clamp
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the `Metal Performance Shader` into the command buffer.
  override public func addMetalPerformanceShaderToBuffer(commandBuffer: MTLCommandBuffer) {
    kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: input!.texture(), destinationTexture: internalTexture!)
  }
}
