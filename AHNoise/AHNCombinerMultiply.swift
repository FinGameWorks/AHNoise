//
//  AHNCombinerMultiply.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by multiplying their colour values with one another. The result is at least as dark as the two inputs.
 
 The input values are multiplied in colour space, and not noise space (0.0 - 1.0 not -1.0 - 1.0).
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when multiplied by another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of -0.64 [0.18 in colour space].
 
 The multiplication is done separately for each colour channel, so the result does not default to greyscale.
 */
public class AHNCombinerMultiply: AHNCombiner {

  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNCombinerMultiply` object.
   
   - parameter input1: The first input that will be multiplied by `input2` to provide the output.
   - parameter input2: The second input that will be multiplied by `input1` to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "multiplyCombiner", input1: input1, input2: input2)
  }
}
