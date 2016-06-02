//
//  AHNModifierStep.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and maps values larger than the `boundary` value to the `highValue`, and those below to the `lowValue`.
 
 
 For example if a pixel has a value of 0.2 [0.6 in colour space] and the `boundary` is set to 0.0 [0.5], the `highValue` set to 0.4 [0.7] and the `lowValue` set to -0.8 [0.1], the returned value will be -0.8 [0.1 in colour space].
 
 The mathematics is carried out on the numbers in colour space, not noise space (0.0 - 1.0 not -1.0 - 1.0].
 
 The output of this module will always be greyscale as the output value is written to all three colour channels equally.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierStep: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///The low, hight and boundary values wrapped in a vector.
  private var values: vector_float3 = vector_float3(0, 1, 0.5)
  
  
  
  ///The low value (default value is 0.0) to output if the noise value is lower than the `boundary`.
  public var lowValue: Float{
    get{
      return values.x
    }
    set{
      values.x = newValue
      dirty = true
    }
  }

  
  
  ///The hight value (default value is 1.0) to output if the noise value is higher than the `boundary`.
  public var highValue: Float{
    get{
      return values.y
    }
    set{
      values.y = newValue
      dirty = true
    }
  }

  
  
  ///The value at which to perform the step. Texture values lower than this are returned as `lowValue` and those above are returned as `highValue`.
  public var boundary: Float{
    get{
      return values.z
    }
    set(newBoundary){
      values.z = newBoundary
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierStep` object.
   
   - parameter input: The input to perform the step on.
   - parameter lowValue: The value to output if the noise value is lower than the `boundary`
   - parameter highValue: The value to output if the noise value is higher than the `boundary`
   - parameter boundary: The value that dictates whether `lowValue` or `highValue` are written to the output. Texture values lower than this are returned as `lowValue` and those above are returned as `highValue`.
   */
  public init(input: AHNTextureProvider, lowValue low: Float, highValue high: Float, boundary: Float){
    super.init(functionName: "stepModifier", input: input)
    self.boundary = boundary
    lowValue = low
    highValue = high
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = values
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float3), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float3))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}