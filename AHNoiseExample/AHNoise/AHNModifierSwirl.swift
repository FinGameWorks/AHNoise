//
//  AHNModifierSwirl.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and swirls its output.
 
 The `angle` property defines how much to swirl the input in radians. The amount each pixel is rotated about the anchor is proportional to its distance from the anchor point.
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change. Corners may be clipped because of this, to avoid losing the corners, resize the canvas first by using an `AHNModifierScaleCanvas` object to provide more room for rotation.
 
 Values are interpolated to avoid pixellation.
 
 The centre point about which the swirl takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is (0.5,0.5).
 
 Where the rotation results in the canvas being partially empty, this can be either left blank by setting `cutEdges` to true, or filled in black if set to false.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierSwirl: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///The rotation intensity, anchor point and cut edges bool wrapped in a vector.
  private var rotate: vector_float4 = vector_float4(0.5, 0.5, 0.5, 1)
  
  
  
  ///The anchor point for horizontal axis about which to swirl the input. Default is 0.5.
  public var xAnchor: Float{
    get{
      return rotate.x
    }
    set{
      rotate.x = newValue
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to swirl the input. Default is 0.5.
  public var yAnchor: Float{
    get{
      return rotate.y
    }
    set{
      rotate.y = newValue
      dirty = true
    }
  }
  
  
  
  ///The intensity of the swirl. Default is 0.5.
  public var intensity: Float{
    get{
      return rotate.z
    }
    set{
      rotate.z = newValue
      dirty = true
    }
  }
  
  
  
  ///When true, the edges of the input are "cut" before the swirl, meaning the black areas off the the canvas are not rotated and any area not covered by the input after rotation is clear. If false, these areas are filled black.
  public var cutEdges: Bool{
    get{
      return rotate.w == 1 ? true : false
    }
    set{
      rotate.w = newValue ? 1 : 0
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierSwirl` object.
   
   - parameter input: The input to swirl.
   - parameter radians: The intensity of the swirl.
   */
  public init(input: AHNTextureProvider, intensity: Float){
    super.init(functionName: "swirlModifier", input: input)
    self.intensity = intensity
  }
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = rotate
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float4), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float4))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}