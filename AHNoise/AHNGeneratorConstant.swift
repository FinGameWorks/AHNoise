//
//  AHNGeneratorConstant.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///Generates a solid colour based on red, green and blue colour values. Can be used to colourise other noise modules.
///
///*Conforms to the `AHNTextureProvider` protocol.*
public class AHNGeneratorConstant: AHNGenerator {
  
  
  // MARK:- Properties
  
  
  ///The red component of the colour to be output in the range `0.0 - 1.0`. The default value is `0.5`.
  public var red: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The green component of the colour to be output in the range `0.0 - 1.0`. The default value is `0.5`.
  public var green: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The blue component of the colour to be output in the range `0.0 - 1.0`. The default value is `0.5`.
  public var blue: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  

  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "uniformGenerator")
  }
  
  
  
  
  
  
  
  
  
  // Argument table update
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float3(red,green,blue)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(vector_float3), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(vector_float3))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
}
