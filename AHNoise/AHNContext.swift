//
//  AHNContext.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal


import UIKit
import Metal


/**
 A wrapper for the `MTLDevice`, `MTLLibrary` and `MTLCommandQueue` used to create the noise textures. Used when generating noise textures using an `AHNGenerator` subclass.
 
 `AHNModifier`, `AHNCombiner` and `AHNSelector` require an `AHNContext` to run, but reference the same `AHNContext` object as their input, which comes from the `Shared Context` class property for `AHNGenerators`.
 */
public class AHNContext: NSObject {
  
  
  // MARK:- Static Functions
  
  ///The shared `AHNContext` object that is used by all `AHNTextureProvider` objects to communicate with the GPU.
  static var SharedContext: AHNContext! = AHNContext.CreateContext()
  
  
  
  ///Set the `MTLDevice` of the `SharedContect` object to a specific object. An `MTLDevice` is a representation of a GPU, so apps for macOS (OSX) will want to set the device to the most powerful graphics hardware available, and not automatically default to onboard graphics.
  static func SetContextDevice(device: MTLDevice){
    SharedContext = CreateContext(device)
  }
  
  
  
  ///- returns: An `AHNContext` object with the specified `MTLDevice`. If no `MTLDevice` is specified then the default is obtained from `MTLCreateSystemDefaultDevice()`.
  private static func CreateContext(device: MTLDevice? = MTLCreateSystemDefaultDevice()) -> AHNContext{
    return AHNContext(device: device)
  }
  
  
  
  
  
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
   
   - parameter device: (Optional) The `MTLDevice` used throughout the `AHNoise` framework..
   */
  private init(device: MTLDevice?) {
    guard let device = device else{
      fatalError("AHNoise: Error creating MTLDevice).")
    }
    self.device = device
    
    guard let library = device.newDefaultLibrary() else{
      fatalError("AHNoise: Error creating default library.")
    }
    self.library = library
    
    commandQueue = device.newCommandQueue()
  }
}
