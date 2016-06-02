//
//  AHNModifierAbsolute.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and performs a mathematical `abs()` function on the pixel values.
 
 The output of the `AHNGenerator` classes returns value in the range -1.0 - 1.0 [0.0 - 1.0 in colour space], this module will perform an absulute function on the input, essentially multiplying any negative values by -1 returning values in the range 0.0 - 1.0 [0.5 - 1.0 in colour space].
 
 If the `normalise` property is true (false by default) then the output values will be remapped to -1.0 - 1.0 [0.0 - 1.0 in colour space], essentially stretching the to fit the original range. 
 
 *Conforms to the `AHNTextureProvider` protocol.*
*/
public class AHNModifierAbsolute: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///If false (default), the output is within the range 0.0 - 1.0 [0.5 - 1.0 in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  private var shouldNormalise: Bool = false
  
  
  
  ///If false (default), the output is within the range 0.0 - 1.0 [0.5 - 1.0 in colour space], if true the output is remapped to cover the whole -1.0 - 1.0 range of the input [0.0 - 1.0 in colour space].
  public var normalise: Bool{
    get{
      return shouldNormalise
    }
    set(new){
      shouldNormalise = new
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierAbsolute` object.
  
   - parameter input: The input to perform the absolute modifier on.
  */
  init(input: AHNTextureProvider){
    super.init(functionName: "absoluteModifier", input: input)
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = shouldNormalise
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(Bool), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(Bool))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}