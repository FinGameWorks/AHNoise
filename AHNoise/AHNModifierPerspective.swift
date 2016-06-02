//
//  AHNModifierPerspective.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd

/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and applies a perspective transform.
 
 The `xCompression` property determines how much the upper portion of the input is compressed horizontally to give the impression of stretching into the distance. Values over 3.3 will result in the texture wrapping. A value of 2-2.5 is a good place to start.
 
 The `yScale` property determines how much the input is scaled in the vertical axis to give an impression of looking at the canvas at a shallow angle. This can range from 0.0 - 1.0. at 0.0 the canvas has zero height, at 1.0 it retains its original height.
 
 The `direction` property allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle.
 
 Values are interpolated to avoid pixellation.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierPerspective: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The compression, scale and direction wrapped in a vector.
  private var perspective: vector_float3 = vector_float3(0.5, 0.5, 0)
  
  
  
  ///Determines how much the upper portion of the input is compressed horizontally to give the impression of stretching into the distance. Values over 3.3 will result in the texture wrapping. A value of 2-2.5 is a good place to start.
  public var xCompression: Float{
    get{
      return perspective.x
    }
    set{
      if newValue > 3.3 { print("AHNoise: WARNING - xCompression values over 3.3 will result in the texture wrapping.") }
      perspective.x = newValue
      dirty = true
    }
  }
  
  
  ///Determines how much the input is scaled in the vertical axis to give an impression of looking at the canvas at a shallow angle. This can range from 0.0 - 1.0. at 0.0 the canvas has zero height, at 1.0 it retains its original height.
  public var yScale: Float{
    get{
      return perspective.y
    }
    set{
      perspective.y = newValue
      dirty = true
    }
  }
  
  
  
  ///Allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle.
  public var direction: Float{
    get{
      return perspective.z
    }
    set{
      perspective.z = newValue
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierPerspective` object.
   
   - parameter input: The input to apply the perspective transform to.
   - parameter compression: Determines how much the upper portion of the input is compressed horizontally to give the impression of stretching into the distance. Values over 3.3 will result in the texture wrapping. A value of 2-2.5 is a good place to start.
   - parameter yScale: Determines how much the input is scaled in the vertical axis to give an impression of looking at the canvas at a shallow angle. This can range from 0.0 - 1.0. at 0.0 the canvas has zero height, at 1.0 it retains its original height.
   */
  public init(input: AHNTextureProvider, compression: Float, yScale: Float){
    super.init(functionName: "perspectiveModifier", input: input)
    xCompression = compression
    self.yScale = yScale
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = perspective
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float3), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float3))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}