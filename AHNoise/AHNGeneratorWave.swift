//
//  AHNGeneratorWave.swift
//  Noise Studio
//
//  Created by App Work on 07/07/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit
import simd


///Struct used to communicate properties to the GPU.
struct WaveInputs {
  var frequency: Float
  var offsetStrength: Float
  var rotations: vector_float3
}


///Generates a series of sinusoidal waves represented by black and white lines.
///
///*Conforms to the `AHNTextureProvider` protocol.*
public class AHNGeneratorWave: AHNGenerator  {
  
  var allowableControls: [String] = ["textureWidth", "textureHeight", "frequency", "offsetStrength", "xRotation", "yRotation", "zRotation"]
  
  
  // MARK:- Properties
  
  
  
  ///Increases the number and compactness of waves visible in the texture. The default value is `1.0`.
  public var frequency: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  required public init(){
    super.init(functionName: "waveGenerator")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = WaveInputs(frequency: frequency, offsetStrength: offsetStrength, rotations: vector_float3(xRotation, yRotation, zRotation))

    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(WaveInputs), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(WaveInputs))
    
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
    super.init(functionName: "waveGenerator")
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
