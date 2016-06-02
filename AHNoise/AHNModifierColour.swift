//
//  AHNModifierColour.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
private struct AHNColourProperties{
  var colour: vector_float4
  var properties: vector_float4
}



/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and colourises it.
 
 Applies a colouring to a specific range of values in a texture. Each pixel is mixed with the input colour with a weighting specified by its value in comparison to the `position`, `lowerRange` and `upperRange` properties. Values that are equal to `position` will have a mix value of 1.0, values equal to the `upperRange` and `lowerRange` will have a mix value of 0.0. The values within the range are linearly interpolated from 0.0 - 1.0 - 0.0.
 
 The default will colour the whole range from -1.0 - 1.0 [0.0 - 1.0 in colour space] and will disperse colour evenly.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierColour: AHNModifier {

  
  // MARK:- Properties
  
  
  /// The colour to apply to the input.
  private var _colour: UIColor
  
  
  
  ///The central position of the colouring range. Pixels with this value in the texture will output the `colour` due to a mix value of 1.0. Default value is 0.5.
  private var _position: Float = 0.5
  
  
  
  /// The lower range of the colouring. The colour mix value is linearly interpolated from the `position` to this value. Default value is 0.5.
  private var _lowerRange: Float = 0.5
  
  

  /// The upper range of the colouring. The colour mix value is linearly interpolated from the `position` to this value. Default value is 0.5.
  private var _upperRange: Float = 0.5
  
  
  
  /// The colour to apply to the input.
  public var colour: UIColor{
    get{
      return _colour
    }
    set{
      _colour = newValue
      dirty = true
    }
  }
  
  
  
  ///The central position of the colouring range. Pixels with this value in the texture will output the `colour` due to a mix value of 1.0. Default value is 0.5.
  public var position: Float{
    get{
      return _position
    }
    set{
      _position = newValue
      dirty = true
    }
  }
  
  
  
  /// The lower range of the colouring. The colour mix value is linearly interpolated from the `position` to this value. Default value is 0.5.
  public var lowerRange: Float{
    get{
      return _lowerRange
    }
    set{
      _lowerRange = newValue
      dirty = true
    }
  }
  
  
  
  /// The upper range of the colouring. The colour mix value is linearly interpolated from the `position` to this value. Default value is 0.5.
  public var upperRange: Float{
    get{
      return _upperRange
    }
    set{
      _upperRange = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierColour` object.
   
   - parameter input: The input to colourise.
   - parameter colour: The `UIColor` to apply to the input.
   */
  public init(input: AHNTextureProvider, colour: UIColor){
    _colour = colour
    super.init(functionName: "colourModifier", input: input)
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    _colour.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    var uniforms = AHNColourProperties(colour: vector_float4(Float(red), Float(green), Float(blue), 1.0), properties: vector_float4(_position, _lowerRange, _upperRange, 1.0))

    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(AHNColourProperties), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(AHNColourProperties))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}


