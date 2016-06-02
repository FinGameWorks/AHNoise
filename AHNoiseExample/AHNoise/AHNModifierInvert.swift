//
//  AHNModifierInvert.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and inverts the values.
 
 For example if a pixel has a value of 0.2 [0.6 in colour space], the output will be -0.2 [0.4]. The values are flipped around 0.0 [0.5].
  
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierInvert: AHNModifier {

  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierInvert` object.
   
   - parameter input: The input to invert the values of.
   */
  public init(input: AHNTextureProvider){
    super.init(functionName: "invertModifier", input: input)
  }
}
