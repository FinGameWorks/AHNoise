//
//  AHNCombinerMin.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by choosing the minimum value of the two.
 
 The value of the output is calculated by first calculating the average value of the three colour channels, then selecting the minimum value and writing the three channels to the output in order to retain colour.
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when compared with another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of -0.4 [0.3 in colour space].
 */
public class AHNCombinerMin: AHNCombiner {

  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNCombinerMin` object.
   
   - parameter input1: The first input that will be compared to `input2` to provide the output.
   - parameter input2: The second input that will be compared to `input1` to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "minCombiner", input1: input1, input2: input2)
  }
}
