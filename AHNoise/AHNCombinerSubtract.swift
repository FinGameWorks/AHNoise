//
//  AHNCombinerSubtract.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by subtracting their colour values from one another.
 
 The input values are subtracted in colour space, and not noise space (0.0 - 1.0 not -1.0 - 1.0). The value of the output is calculated using: `output = input1.rgb - input2.rgb`.
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when subtracted from another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of -0.4 [0.3 in colour space].
 
 Resultant values lower than -1.0 [0.0] will show as black. The subtraction is done separately for each colour channel, so the result does not default to greyscale.
 */
public class AHNCombinerSubtract: AHNCombiner {
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNCombinerSubtract` object.
      
   - parameter input1: The first input that will have `input2` subtracted from it to provide the output.
   - parameter input2: The second input that will be subtracted from `input1` to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "subtractCombiner", input1: input1, input2: input2)
  }
}
