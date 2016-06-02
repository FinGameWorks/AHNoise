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
  
  
  private var r: Float
  private var g: Float
  private var b: Float
  
  
  
  ///The red colour component of the ouput colour.
  var red: Float{
    get{
      return r
    }
    set(newRed){
      r = newRed
      dirty = true
    }
  }
  
  
  
  ///The green colour component of the ouput colour.
  var green: Float{
    get{
      return g
    }
    set(newGreen){
      g = newGreen
      dirty = true
    }
  }
  
  
  
  ///The blue colour component of the ouput colour.
  var blue: Float{
    get{
      return b
    }
    set(newBlue){
      b = newBlue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNGeneratorConstant` object.
   - parameter context: The `AHNContext` object that will be used to create the buffers and command encoders required.
   - parameter textureWidth: The desired width of the output texture in pixels.
   - parameter textureHeight: The desired height of the output texture in pixels.
   - parameter red: The red colour component of the ouput colour.
   - parameter green: The green colour component of the ouput colour.
   - parameter blue: The blue colour component of the ouput colour.
   */
  public init(context: AHNContext, textureWidth width: Int, textureHeight height: Int, red: Float, green: Float, blue: Float){
    r = red
    g = green
    b = blue
    super.init(functionName: "uniformGenerator", context: context, textureWidth: width, textureHeight: height, use4DNoise: false, mapForSphere: false, makeSeamless: false)
  }
  
  
  
  
  
  
  
  
  
  // Argument table update
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float3(r,g,b)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(vector_float3), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(vector_float3))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }

}
