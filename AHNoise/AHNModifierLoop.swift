//
//  AHNModifierLoop.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
private struct LoopModifierUniforms {
  var normalise: Bool
  var loopValue: Float
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and loops or wraps pixel values to never exceed a specified `loopValue` property.
 
 The output of the `AHNGenerator` classes returns value in the range -1.0 - 1.0 [0.0 - 1.0 in colour space], where a noise value exceed the `loopValue` property, the value will be looped back to zero. This looping can occur multiple times.
 
 For example if a pixel has a value of 0.2 [0.6 in colour space] and the `loopValue` property is set to 0.5, the returned value will be -0.8 [0.1 in colour space].
 
 The mathematics is carried out on the numbers in colour space, not noise space (0.0 - 1.0 not -1.0 - 1.0].
 
 The output of this module will always be greyscale as the colour channels are averaged to grey during the calculations.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierLoop: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///The value to loop at (default is 0.5). No colour value will exceed this value (unless `normalise` is set to `true`.
  private var loop: Float = 0.5
  
  
  
  ///If false (default), the output is within the range -1.0 - `((loopValue*2)-1)` [0.0 - `loopValue` in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  private var shouldNormalise: Bool = false
  
  
  
  ///The value to loop at (default is 0.5). No colour value will exceed this value (unless `normalise` is set to `true`.
  public var loopValue: Float{
    get{
      return loop
    }
    set{
      if newValue <= 0 || newValue > 1{
        print("AHNoise: WARNING - Loop at a value less than 0 or greater than 1 will result in full black texture for 0 or no effect for >1. Currently \(newValue)")
      }
      loop = newValue
      dirty = true
    }
  }
  
  
  
  ///If false (default), the output is within the range -1.0 - `((loopValue*2)-1)` [0.0 - `loopValue` in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  public var normalise: Bool{
    get{
      return shouldNormalise
    }
    set{
      shouldNormalise = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierLoop` object.
   
   - parameter input: The input to perform the loop on.
   - parameter loopEvery: The value to loop at.
   */
  public init(input: AHNTextureProvider, loopEvery loop: Float){
    super.init(functionName: "loopModifier", input: input)
    loopValue = loop
  }
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = LoopModifierUniforms(normalise: shouldNormalise, loopValue: loop)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(LoopModifierUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(LoopModifierUniforms))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}