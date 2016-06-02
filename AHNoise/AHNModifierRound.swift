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
 
 The output of the `AHNGenerator` classes returns value in the range -1.0 - 1.0 [0.0 - 1.0 in colour space], this module will perform a round function on the input to return values that are integer multiples of a specified value.
 
 Where i is the input value, o is the output value and r is the value to round to, the function is: `o = r*(round(i/r))`.
 
 For example if a pixel has a value of 0.2 [0.6 in colour space] and the `roundValue` property is set to 0.5, the returned value will be 0.0 [0.5 in colour space], 0.4 [0.7] would return 0.5 [0.75].
 
 The mathematics is carried out on the numbers in colour space, not noise space (0.0 - 1.0 not -1.0 - 1.0].
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierRound: AHNModifier {
  
  
  // MARK:- Properties
  
  
  /**
   The value that the texture values will be rounded to multiples of, using the formula `o = r*(round(i/r))`.
   
   Default value is 1, causing no effect.
   */
  private var round: Float = 1
  
  
  
  /**
   The value that the texture values will be rounded to multiples of, using the formula `o = r*(round(i/r))`.
   
   Default value is 1, causing no effect.
  */
  public var roundValue: Float{
    get{
      return round
    }
    set{
      assert(newValue != 0, "Cannot round to zero as this involved division by zero. To round to nearest integer set roundValue to 1.")
      if newValue <= 0 || newValue > 1{
        print("AHNoise: WARNING - Rounding to a value less than 0 or greater than 1 will result in full black and white texture")
      }
      round = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
  Creates a new `AHNModifierRound` object.
  
  - parameter input: The input to perform the `round()` on.
  - parameter min: The value to round the noise values to multiples of.
  */
  public init(input: AHNTextureProvider, roundToNearest round: Float){
    super.init(functionName: "roundModifier", input: input)
    roundValue = round
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = round
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(Float), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(Float))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}