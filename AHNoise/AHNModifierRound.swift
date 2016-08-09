//
//  AHNModifierRound.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and rounds pixel values to an integer multiple of the`roundValue` property.
 
 Where `i` is the input value, `o` is the output value and `r` is the value to round to, the function is: `o = r*(round(i/r))`.
 
 For example if a pixel has a value of `0.6` and the `roundValue` property is set to `0.5`, the returned value will be `0.5`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierRound: AHNModifier {
  
  
  // MARK:- Properties
  
  
  /**
   The value that the texture values will be rounded to multiples of.
   
   Default value is `1.0`, causing no effect.
   */
  public var roundValue: Float = 1{
    didSet{
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "roundModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = roundValue
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(Float), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(Float))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}