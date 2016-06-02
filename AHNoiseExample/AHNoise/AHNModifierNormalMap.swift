//
//  AHNModifierNormalMap.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
private struct NormalMapModifierUniforms {
  var intensity: Float
  var axes: vector_int2
}



/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and turns it into a normal map.
 
 The value of each colour channel is averaged into one value per pixel. This value is then compared to adjacent pixels and the gradient of the pixel is calculated and the ouput colour is calculated using the standard normal map colours.
 
 The `intensity` property dictates how much the gradient on a pixel is translated into the colour for each axis.
 
 The direction of the x and y axes can be inverted using the `invertX` and `invertY` properties.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierNormalMap: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///The boolean values of axis flipping wrapped in a vector
  private var axes: vector_int2 = vector_int2(0, 0)
  
  
  
  ///The intensity of the normal map, higher values make edges appear deeper. (values between 0.0 - 1.0 are a good start)
  private var _intensity: Float = 50
  
  
  
  ///Toggles which direction along the y axis appears lighter, and which darker.
  public var invertY: Bool{
    get{
      return axes.x == 0 ? false : true
    }
    set{
      axes.x = newValue ? 1 : 0
      dirty = true
    }
  }
  
  
  
  ///Toggles which direction along the x axis appears lighter, and which darker.
  public var invertX: Bool{
    get{
      return axes.y == 0 ? false : true
    }
    set{
      axes.y = newValue ? 1 : 0
      dirty = true
    }
  }
  
  
  
  ///The intensity of the normal map, higher values make edges appear deeper. (values between 0.0 - 1.0 are a good start)
  public var intensity: Float{
    get{
      return _intensity/100
    }
    set{
      _intensity = newValue * 100
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierNormalMap` object.
   
   - parameter input: The input to create a normal map for.
   */
  public init(input: AHNTextureProvider){
    super.init(functionName: "normalMapModifier", input: input)
  }
  

  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = NormalMapModifierUniforms(intensity: intensity, axes: axes)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(NormalMapModifierUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(NormalMapModifierUniforms))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}