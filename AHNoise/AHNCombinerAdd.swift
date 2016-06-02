//
//  AHNCombinerAdd.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by adding their colour values together.
 
 The input values are added in colour space, and not noise space (0.0 - 1.0 not -1.0 - 1.0) meaning the result should always be at least as "light" as the lightest of the two inputs.
 
 For example a pixel with a noise value of -0.4 [0.3 in colour space] when added to another pixel with a noise value of 0.2 [0.6 in colour space] will result in a noise value of 0.8 [0.9 in colour space].
 
 The `normalise` property indicates whether or not the resulting value (0.6 [0.8] in the above example) should be normalised (divided by two) to return the output the the original value range and preventing output values from exceeding 1.0 [1.0]. Setting this to `true` results in the ouput being the average of the two inputs.
 
 Resultant values larger than 1.0 [1.0] will show as white. The addition is done separately for each colour channel, so the result does not default to greyscale.
 */
public class AHNCombinerAdd: AHNCombiner {
  
  
  // MARK:- Properties
  
  
  ///When set to `true` (false by default) the output value range is remapped back to -1.0 - 1.0 [0.0 - 1.0 in colour space] to prevent overly bright areas where the combination of inputs has exceeded 1.0 [1.0]. Setting this to true results in the output being the average of the two inputs.
  private var shouldNormalise: Bool = false
  
  
  
  ///When set to `true` the output value range is remapped back to -1.0 - 1.0 [0.0 - 1.0 in colour space] to prevent overly bright areas where the combination of inputs has exceeded 1.0 [1.0]. Setting this to true results in the output being the average of the two inputs.
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
   Creates a new `AHNCombinerAdd` object.
      
   - parameter input1: The first input that will be added to `input2` to provide the output.
   - parameter input2: The second input that will be added to `input1` to provide the output.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider){
    super.init(functionName: "addCombiner", input1: input1, input2: input2)
  }

  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNCombiner` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = shouldNormalise
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(Bool), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(Bool))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}
