//
//  AHNContext.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal


/**
A wrapper for the `MTLDevice`, `MTLLibrary` and `MTLCommandQueue` used to create the noise textures. Used when generating noise textures using an `AHNGenerator` subclass.
 
 `AHNModifier`, `AHNCombiner` and `AHNSelector` require an `AHNContext` to run, but reference the same `AHNContext` object as their input. As an `AHNGenerator` has no input textures, an `AHNContext`
 object must be supplied on initialisation.
*/
public class AHNContext: NSObject {
  
  
  // MARK:- Properties
  
  
  ///The `MTLDevice` used by the various noise classes to create buffers, pipelines and command encoders.
  public let device: MTLDevice
  
  
  
  ///The `MTLLibrary` that stores the `Metal` kernel functions used to create an manipulate noise.
  public let library: MTLLibrary
  
  
  
  ///The `MTLCommandQueue` that is used to create `MTLCommandEncoder`s for each kernel.
  public let commandQueue: MTLCommandQueue
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNContext` object for use with `AHNoise` modules.
   
   - parameter device: (Optional) The `MTLDevice` used throughout the `AHNoise` framework. If no `MTLDevice` is specified then the default is obtained from `MTLCreateSystemDefaultDevice()`.
  */
  public init(device: MTLDevice? = MTLCreateSystemDefaultDevice()) {
    guard let device = device else{
      fatalError("AHNoise: Error creating system default device.")
    }
    self.device = device
    
    guard let library = device.newDefaultLibrary() else{
      fatalError("AHNoise: Error creating default library.")
    }
    self.library = library
    
    commandQueue = device.newCommandQueue()
  }
}
