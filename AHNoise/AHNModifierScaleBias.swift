//
//  AHNModifierScaleBias.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and applies a scale (multiplier) and a bias (constant).
 
 Where `o` is the output, `i` is the `input`, `s` is the `scale` and `b` is the `bias`: `o=(i*s)+b`.
 
 For example if a pixel has a value of 0.2 [0.6 in colour space], with a `scale` of 0.5 and a `bias` of 0.6, the output would be `(0.6*0.5)+0.6` which equals 0.8 [0.9].
 
 The mathematics is carried out on the numbers in colour space, not noise space (0.0 - 1.0 not -1.0 - 1.0].
 
 This can be used to shift the range of values an `AHNTextureProvider` has.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierScaleBias: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The `scale` and `bias` values wrapped in a vector.
  private var values: vector_float2 = vector_float2(1, 0)
  
  
  
  ///The multiplier to apply to the `input` value before the addition of `bias`. Default value is 1.0.
  public var scale: Float{
    get{
      return values.x
    }
    set{
      values.x = newValue
      dirty = true
    }
  }
  
  
  
  ///The constant to add to the `input` after it has been multiplied by `scale`. Can be negative. Default Value is 0.0.
  public var bias: Float{
    get{
      return values.y
    }
    set{
      values.y = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierScaleBias` object.
   
   - parameter input: The input to perform the scale bias on.
   - parameter scale: The value to multiply the `input` by before the addition of `bias`.
   - parameter bias: The value to add to the `input` after it has been multiplied by `scale`.
   */
  public init(input: AHNTextureProvider, scale: Float, bias: Float){
    super.init(functionName: "scaleBiasModifier", input: input)
    self.scale = scale
    self.bias = bias
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = values
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float2), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float2))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}