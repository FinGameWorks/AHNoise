//
//  AHNCombinerDivide.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by dividing their colour values by one another.
 
 The input values are divided in colour space, and not noise space (0.0 - 1.0 not -1.0 - 1.0). The value of the output is calculated using: `output = input1.rgb / input2.rgb`.
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when divided by another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of 0.0 [0.5 in colour space].
 
 Resultant values larger than 1.0 [1.0] will show as white, and lower than -1.0 [0.0] will show as black. The multiplication is done separately for each colour channel, so the result does not default to greyscale.
 */
public class AHNCombinerDivide: AHNCombiner {

  // MARK:- Initialiser
  
  /**
   Creates a new `AHNCombinerDivide` object.
   
   - parameter input1: The first input that will be divided by `input2` to provide the output.
   - parameter input2: The second input that `input1` will be divided by to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "divideCombiner", input1: input1, input2: input2)
  }
}
