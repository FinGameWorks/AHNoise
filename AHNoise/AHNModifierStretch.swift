//
//  AHNModifierStretch.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and stretches its output.
 
 The `xFactor` and `yFactor` properties define how much to stretch the input in each direction. A factor of `1.0` will result in no change in that axis, but a factor of `2.0` will result in the dimension of that axis being doubled. Factors less than `1.0` can be used to shrink a canvas. The default is (`1.0,1.0`)
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change.
 
 Values are interpolated to avoid pixellation.
  
 The centre point about which the stretch takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is `(0.5,0.5)`
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierStretch: AHNModifier {

  
  // MARK:- Properties
  
  var allowableControls: [String] = ["xFactor", "yFactor", "xAnchor", "yAnchor"]
  
  
  
  ///The factor to stretch the input by in the horizontal axis. Default value is `1.0`.
  public var xFactor: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The factor to stretch the input by in the vertical axis. Default value is `1.0`.
  public var yFactor: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for horizontal axis about which to stretch the input. Default is `0.5`.
  public var xAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to stretch the input. Default is `0.5`.
  public var yAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "stretchModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float4(xFactor, yFactor, xAnchor, yAnchor)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(vector_float4), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(vector_float4))
    
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
    super.init(functionName: "stretchModifier")
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
