//
//  AHNModifierBlur.swift
//  AHNoise
//
//  Created by Andrew Heard on 19/05/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import Metal
import simd
import MetalPerformanceShaders


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and blurs its texture.
 
 The input undergoes a Gaussian blur with a specified `radius`. Note that this is computationally expensive for larger radii.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierBlur: AHNModifier {
  
  var allowableControls: [String] = ["radius"]
  
  // MARK:- Properties
  
  
  ///The radius of the Gaussian blur. The default value is `3.0`.
  public var radius: Float = 3{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The `Metal Performance Shader` used to perform the blur.
  var kernel: MPSImageGaussianBlur!
  
  
  


  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "normalMapModifier")
    usesMPS = true
    kernel = MPSImageGaussianBlur(device: context.device, sigma: radius)
    kernel.edgeMode = .Clamp
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the `Metal Performance Shader` into the command buffer. This is called by the superclass and should not be called manually.
  override public func addMetalPerformanceShaderToBuffer(commandBuffer: MTLCommandBuffer) {
    guard let texture = provider?.texture() else { return }
    kernel = MPSImageGaussianBlur(device: context.device, sigma: radius)
    kernel.edgeMode = .Clamp
    kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: texture, destinationTexture: internalTexture!)
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
    super.init(functionName: "normalMapModifier")
    usesMPS = true
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
