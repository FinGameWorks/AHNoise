//
//  AHNCombinerPower.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by raising the power of the first input to the second input.
 
 The input values are calculated in colour space, and not noise space (0.0 - 1.0 not -1.0 - 1.0). The value of the output is calculated using: `output = pow(input1.rgb, input2.rgb)`.
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when raised to the power of another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of -0.029 [0.486 in colour space].
 
 The multiplication is done separately for each colour channel, so the result does not default to greyscale.
 */
public class AHNCombinerPower: AHNCombiner {

  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNCombinerPower` object.
   
   - parameter input1: The first input that will be raised to the power of `input2` to provide the output.
   - parameter input2: The second input that `input1` will be raised to the power of to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "powerCombiner", input1: input1, input2: input2)
  }
}
