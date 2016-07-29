//
//  AHNModifierAbsolute.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and performs a mathematical `abs()` function on the pixel values.
 
 Pixel values are in the range `0.0 - 1.0`, and apply the `abs()` function to this range would have no effect. This means the pixel valeus must be converted back to the original `-1.0 - 1.0` noise range, then perform the `abs()` function, then finally convert back into the colour range `0.0 - 1.0`. This results in outputs in the range `0.5 - 1.0`.
 
 If the `normalise` property is `true` (`false` by default) then the output values will be remapped to `0.0 - 1.0`, essentially stretching the to fit the original range.
 
 *Conforms to the `AHNTextureProvider` protocol.*
*/
public class AHNModifierAbsolute: AHNModifier {
  
  public var allowableControls: [String] = ["normalise"]

  
  // MARK:- Properties
  
  
  ///If `false` (the default), the output is within the range `0.5 - 1.0`, if `true` the output is remapped to cover the whole `0.0 - 1.0` range of the input.
  public var normalise: Bool = false{
    didSet{
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "absoluteModifier")
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = normalise
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(Bool), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(Bool))
    
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
    super.init(functionName: "absoluteModifier")
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