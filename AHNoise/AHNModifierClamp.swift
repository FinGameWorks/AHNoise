//
//  AHNModifierClamp.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
private struct ClampModifierUniforms {
  var normalise: Bool
  var clampValues: vector_float2
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and performs a `clamp()` function on the pixel values.
 
 The output of the `AHNGenerator` classes returns value in the range -1.0 - 1.0 [0.0 - 1.0 in colour space], this module will perform a clamp function on the input, reverting any values over a specified maximum value to that maximum value, and the same for any values less than a specified minimum value. If the `normalise` property is true (false by default) then the output values will be remapped to -1.0 - 1.0 [0.0 - 1.0 in colour space], essentially stretching the to fit the original range.
 
 For example if a pixel has a value of 0.8 [0.9 in colour space] and the `maximum` property is set to 0.5 [0.75 in colour space], the returned value will be 0.5 [0.75 in colour space]. The same applies for a value less than the minimum value. 
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierClamp: AHNModifier {
  
  // MARK:- Properties
  
  
  ///The minimum and maximum values to be clamped to, wrapped in a vector.
  private var clampValues: vector_float2 = vector_float2(0,1)
  
  
  
  ///If false (default), the output is within the range 0.0 - 1.0 [0.5 - 1.0 in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  private var shouldNormalise: Bool = false
  
  
  
  ///If false (default), the output is within the range 0.0 - 1.0 [0.5 - 1.0 in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  public var normalise: Bool{
    get{
      return shouldNormalise
    }
    set{
      shouldNormalise = newValue
      dirty = true
    }
  }
  
  
  
  ///The minimum value to clamp to (default is 0), if a value in a texture is less than this value, this value will be returned instead.
  public var minimum: Float{
    get{
      return clampValues.x
    }
    set{
      clampValues.x = newValue
      dirty = true
    }
  }
  
  
  
  ///The maximum value to clamp to (default is 1), if a value in a texture is more than this value, this value will be returned instead.
  public var maximum: Float{
    get{
      return clampValues.y
    }
    set{
      clampValues.y = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  /**
  Creates a new `AHNModifierClamp` object.
  
  - parameter input: The input to perform the `clamp()` modifier on.
  - parameter min: The minimum value to clamp to.
  - parameter max: The maximum value to clamp to.
  */
  public init(input: AHNTextureProvider, min: Float, max: Float){
    assert(max>min, "Max value must be larger than min value")
    super.init(functionName: "clampModifier", input: input)
    minimum = min
    maximum = max
  }

  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = ClampModifierUniforms(normalise: shouldNormalise, clampValues: clampValues)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(ClampModifierUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(ClampModifierUniforms))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}