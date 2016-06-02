//
//  AHNSelectorBlend.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Blends two input `AHNTextureProvider`s together using a weight from a third input `AHNTextureProvider` used as the `selector`.
 
 The input `AHNTextureProvider`s may range from a value of -1.0 - 1.0 [0.0 - 1.0 in colour space]. This value is taken from the `selector` for each pixel to provide a mixing weight for the two `input`s. A value of -1.0 [0.0] will output 100% `input1` and 0% `input2`, while a value of 1.0 [1.0] will output 100% `input2` and 0% `input1`. A value of -0.5 [0.25] will output a mixture of 75% `input1` and 25% `input2`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNSelectorBlend: AHNSelector {
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNSelectorBlend` object.
   
   - parameter input1: The first input that will be combined with `input2` using `selector` to provide the output.
   - parameter input2: The second input that will be combined with `input1` using `selector` to provide the output.
   - parameter selector: The `AHNTextureProvider` that selects how much of each input to write to the output `MTLTexture` depending on its value at each pixel.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider, selector: AHNTextureProvider){
    super.init(functionName: "blendSelector", input1: input1, input2: input2, selector: selector)
  }
}
