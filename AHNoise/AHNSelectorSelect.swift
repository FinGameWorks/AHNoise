//
//  AHNSelectorSelect.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Selects one of two input `AHNTextureProvider`s to write to the output using a weight from a third input `AHNTextureProvider` used as the `selector`.
 
 The input `AHNTextureProvider`s may range from a value of -1.0 - 1.0 [0.0 - 1.0 in colour space]. This value is taken from the `selector` `AHNTextureProvider` for each pixel to select which input to write to the output `MTLTexture`. A `selector` value between -1.0 - 0.0 [0.0 - 0.5] will result in `input1` being written to the output, whereas a `selector` value between 0.0 - 1.0 [0.5 - 1.0] will result in `input2` being written to the output. `selector` values equal to 0.0 will always write `input1` to the output.
 
 The `edgeTransition` property is used to define how abruptly the transition occurs between the two inputs. A value of 0.0 will result in no transition. Higher values cause the transition to be softened by interpolating between the two inputs at the border between them. A maximum value of 1.0 results in the edge transition covering the whole of the two inputs.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNSelectorSelect: AHNSelector {
  
  
  // MARK:- Properties
  
  
  /** 
   The amount the transition between the two inputs should be softened (0.0 - 1.0).
   
   Values outside the range (0.0 - 1.0) may result in undesired behaviour.
   
   Default value is 0.0.
 */
  private var edge: Float = 0
  
  
  
  /**
   The amount the transition between the two inputs should be softened (0.0 - 1.0).
   
   Values outside the range (0.0 - 1.0) may result in undesired behaviour.
   
   Default value is 0.0.
   */
  public var edgeTransition: Float{
    get{
      return edge
    }
    set{
      edge = newValue
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNSelectorSelect` object.
   
   - parameter input1: The first input that will be combined with `input2` using `selector` to provide the output.
   - parameter input2: The second input that will be combined with `input1` using `selector` to provide the output.
   - parameter selector: The `AHNTextureProvider` that selects how much of each input to write to the output `MTLTexture` depending on its value at each pixel.
   */
  public init(input1: AHNTextureProvider, input2: AHNTextureProvider, selector: AHNTextureProvider){
    super.init(functionName: "selectSelector", input1: input1, input2: input2, selector: selector)
  }

  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNSelector` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandEncoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = edge
    
    // Create the uniform buffer
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(Float), options: .CPUCacheModeDefaultCache)
    }
    
    // Copy latest arguments
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(Float))
    
    // Set the buffer in the argument table
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}
