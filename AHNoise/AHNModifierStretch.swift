//
//  AHNModifierStretch.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and stretches its output.
 
 The `xFactor` and `yFactor` properties define how much to stretch the input in each direction. A factor of 1.0 will result in no change in that axis, but a factor of 2.0 will result in the dimension of that axis being doubled. Factors less than 1.0 can be used to shrink a canvas. The default is (1.0,1.0)
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change.
 
 Values are interpolated to avoid pixellation.
  
 The centre point about which the stretch takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is (0.5,0.5)
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierStretch: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The anchors and factors wrapped into a vector for communication with the GPU.
  private var stretch: vector_float4 = vector_float4(1, 1, 0.5, 0.5)
  
  
  
  ///The factor to stretch the input by in the horizontal axis. Default value is 1.0.
  public var xFactor: Float{
    get{
      return stretch.x
    }
    set{
      stretch.x = newValue
      dirty = true
    }
  }
  
  
  
  ///The factor to stretch the input by in the vertical axis. Default value is 1.0.
  public var yFactor: Float{
    get{
      return stretch.y
    }
    set{
      stretch.y = newValue
      dirty = true
    }
  }
  
  
  
  ///The anchor point for horizontal axis about which to stretch the input. Default is 0.5.
  public var xAnchor: Float{
    get{
      return stretch.z
    }
    set{
      stretch.z = newValue
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to stretch the input. Default is 0.5.
  public var yAnchor: Float{
    get{
      return stretch.w
    }
    set{
      stretch.w = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierStretch` object.
   
   - parameter input: The input to stretch.
   - parameter xStretchFactor: The factor to stretch the input by in the horizontal axis.
   - parameter yStretchFactor: The factor to stretch the input by in the vertical axis.
   */
  public init(input: AHNTextureProvider, xStretchFactor x: Float, yStretchFactor y: Float){
    super.init(functionName: "stretchModifier", input: input)
    xFactor = x
    yFactor = y
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = stretch
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float4), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float4))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}
