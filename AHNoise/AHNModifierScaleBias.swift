//
//  AHNModifierScaleBias.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and applies a scale (multiplier) and a bias (constant).
 
 Where `o` is the output, `i` is the `input`, `s` is the `scale` and `b` is the `bias`: `o=(i*s)+b`.
 
 For example if a pixel has a value of `0.6`, with a `scale` of `0.5` and a `bias` of `0.6`, the output would be `(0.6*0.5)+0.6` which equals `0.9`.
 
 This can be used to shift the range of values an `AHNTextureProvider` has.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierScaleBias: AHNModifier {

  
  // MARK:- Properties
  
  var allowableControls: [String] = ["scale", "bias"]

  
  
  
  
  ///The multiplier to apply to the `input` value before the addition of `bias`. Default value is `1.0`.
  public var scale: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The constant to add to the `input` after it has been multiplied by `scale`. Can be negative. Default Value is `0.0`.
  public var bias: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "scaleBiasModifier")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float2(scale, bias)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(vector_float2), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(vector_float2))
    
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
    super.init(functionName: "scaleBiasModifier")
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