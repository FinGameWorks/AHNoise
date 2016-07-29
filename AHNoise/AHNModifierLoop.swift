//
//  AHNModifierLoop.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
struct LoopModifierUniforms {
  var normalise: Bool
  var loopValue: Float
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and loops or wraps pixel values to never exceed a specified `loopValue` property.
 
 Values above the `boundary` are replaced with remainder from the result of dividing the value by the `boundary`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierLoop: AHNModifier {
  
  var allowableControls: [String] = ["boundary", "normalise"]
  
  // MARK:- Properties
  
  
  ///The value to loop at. No texture value will exceed this value (unless `normalise` is set to `true`). The default value is `0.5`.
  public var boundary: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///If `false`, the output is within the range `0.0 - loopValue`, if `true` the output is remapped to cover the whole `0.0 - 1.0` range. The default value is `false`.
  public var normalise: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
    
  
  required public init(){
    super.init(functionName: "loopModifier")
  }
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = LoopModifierUniforms(normalise: normalise, loopValue: boundary)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(LoopModifierUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(LoopModifierUniforms))
    
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
    super.init(functionName: "loopModifier")
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