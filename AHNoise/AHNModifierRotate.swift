//
//  AHNModifierRotate.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and rotates its output.
 
 The `angle` property defines how much to rotate the input in radians.
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change. Corners may be clipped because of this, to avoid losing the corners, resize the canvas first by using an `AHNModifierScaleCanvas` object to provide more room for rotation.
 
 Values are interpolated to avoid pixellation.
 
 The centre point about which the rotation takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is `(0.5,0.5)`.
 
 Where the rotation results in the canvas being partially empty, this can be either left blank by setting `cutEdges` to `true`, or filled in black if set to `false`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierRotate: AHNModifier {

  
  // MARK:- Properties
  
  var allowableControls: [String] = ["xAnchor", "yAnchor", "angle", "cutEdges"]
  
  
  
  
  ///The anchor point for horizontal axis about which to rotate the input. The default value is `0.5`.
  public var xAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to rotate the input. The default value is `0.5`.
  public var yAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The angle to rotate the input by in radians. The default value is `0.0`.
  public var angle: Float = 0.0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///When true, the edges of the input are "cut" before the rotation, meaning the black areas off the the canvas are not rotated and any area not covered by the input after rotation is clear. If false, these areas are filled black. The default value is `true`.
  public var cutEdges: Bool = true{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "rotateModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float4(xAnchor, yAnchor, angle, cutEdges ? 1 : 0)
    
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
    super.init(functionName: "rotateModifier")
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