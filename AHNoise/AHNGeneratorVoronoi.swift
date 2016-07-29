//
//  AHNGeneratorVoronoi.swift
//  Noise Studio
//
//  Created by App Work on 23/06/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit
import simd


///Struct used to communicate properties to the GPU.
struct VoronoiInputs {
  var pos: vector_float2
  var offsetStrength: Float
  var rotations: vector_float3
  var octaves: Int32
  var persistance: Float
  var frequency: Float
  var lacunarity: Float
  var zValue: Float
  var wValue: Float
  var sphereMap: Int32
  var seamless: Int32
}


///Generates a texture of discrete cells, useful for representing crystals or dried mud. The noise created lies within the range `0.0 - 1.0`.
///
///*Conforms to the `AHNTextureProvider` protocol.*
public class AHNGeneratorVoronoi: AHNGeneratorCoherent {

  
  var allowableControls: [String] = ["seamless", "frequency", "octaves", "xValue", "yValue", "zValue", "wValue", "persistance", "lacunarity", "textureWidth", "textureHeight", "offsetStrength", "xRotation", "yRotation", "zRotation"]
  
  
  

  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "voronoiGenerator")
    octaves = 1
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = VoronoiInputs(pos: vector_float2(xValue, yValue), offsetStrength: offsetStrength, rotations: vector_float3(xRotation, yRotation, zRotation), octaves: Int32(octaves), persistance: persistance, frequency: frequency, lacunarity: lacunarity, zValue: zValue, wValue: wValue, sphereMap: sphereMap ? 1 : 0, seamless: seamless ? 1 : 0)
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(VoronoiInputs), options: .CPUCacheModeDefaultCache)
    }
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(VoronoiInputs))
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- NSCoding
  public func encodeWithCoder(aCoder: NSCoder) {
    var mirror = Mirror(reflecting: self)
    repeat{
      for child in mirror.children{
        if allowableControls.contains(child.label!){
          if child.value is Int{
            aCoder.encodeInteger(child.value as! Int, forKey: child.label!)
          }
          if child.value is Float{
            aCoder.encodeFloat(child.value as! Float, forKey: child.label!)
          }
          if child.value is Bool{
            aCoder.encodeBool(child.value as! Bool, forKey: child.label!)
          }
        }
      }
      mirror = mirror.superclassMirror()!
    }while String(mirror.subjectType).hasPrefix("AHN")
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(functionName: "voronoiGenerator")
    var mirror = Mirror(reflecting: self.dynamicType.init())
    repeat{
      for child in mirror.children{
        if allowableControls.contains(child.label!){
          if child.value is Int{
            let val = aDecoder.decodeIntegerForKey(child.label!)
            setValue(val, forKey: child.label!)
          }
          if child.value is Float{
            let val = aDecoder.decodeFloatForKey(child.label!)
            setValue(val, forKey: child.label!)
          }
          if child.value is Bool{
            let val = aDecoder.decodeBoolForKey(child.label!)
            setValue(val, forKey: child.label!)
          }
        }
      }
      mirror = mirror.superclassMirror()!
    }while String(mirror.subjectType).hasPrefix("AHN")
  }
}