//
//  AHNModifierPerspective.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd

/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and applies a perspective transform.
 
 The `xCompression` property determines how much the upper portion of the input is compressed horizontally to give the impression of stretching into the distance. Values over `3.3` will result in the texture wrapping. A value of `2 - 2.5` is a good place to start.
 
 The `yScale` property determines how much the input is scaled in the vertical axis to give an impression of looking at the canvas at a shallow angle. This can range from `0.0 - 1.0`. at `0.0` the canvas has zero height, at `1.0` it retains its original height.
 
 The `direction` property allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle.
 
 Values are interpolated to avoid pixellation.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierPerspective: AHNModifier {

  
  // MARK:- Properties
  
  var allowableControls: [String] = ["xCompression", "yScale", "direction"]

  
  ///The amount to compress the texture horizontally to give the impression of stretching into the distance. Values over `3.3` will result in the texture wrapping. A value of `2 - 2.5` is a good place to start. The default value is `2`.
  public var xCompression: Float = 2{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The amount to scale the texture vertically to give an impression of looking at the canvas at a shallow angle. This can range from `0.0 - 1.0`. at `0.0` the canvas has zero height, at `1.0` it retains its original height. The default value is `0.5`.
  public var yScale: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///Allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle. The default value is `0.0.`
  public var direction: Float = 0{
    didSet{
      dirty = true
    }
  }


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "perspectiveModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float3(xCompression, yScale, direction)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(vector_float3), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(vector_float3))
    
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
    super.init(functionName: "perspectiveModifier")
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