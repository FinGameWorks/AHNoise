//
//  AHNSelectorSelect.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Selects one of two input `AHNTextureProvider`s to write to the output using a weight from a third input `AHNTextureProvider` used as the `selector`.
 
 The input `AHNTextureProvider`s may range from a value of `0.0 - 1.0`. This value is taken from the `selector` `AHNTextureProvider` for each pixel to select which input to write to the output `MTLTexture`. A `selector` value between `0.0 - 0.5` will result in `provider` being written to the output, whereas a `selector` value between `0.5 - 1.0` will result in `provider2` being written to the output. `selector` values equal to `0.0` will always write `provider` to the output.
 
 The `edgeTransition` property is used to define how abruptly the transition occurs between the two inputs. A value of `0.0` will result in no transition. Higher values cause the transition to be softened by interpolating between the two inputs at the border between them. A maximum value of `1.0` results in the edge transition covering the whole of the two inputs.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNSelectorSelect: AHNSelector {
  
  
  // MARK:- Properties
  
  var allowableControls: [String] = ["transition", "boundary"]
  
  /** 
   The amount the transition between the two inputs should be softened `(0.0 - 1.0)`.
   
   Values outside the range `(0.0 - 1.0)` may result in undesired behaviour.
   
   Default value is `0.0`.
 */
  var transition: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The boundary that the selector value is compared to. Values larger than this boundary will output `provider2`, and less than this will output `provider`. The default value is `0.5`.
  var boundary: Float = 0.5{
    didSet{
      dirty = true
    }
  }


  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "selectSelector")
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNSelector` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandEncoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float2(transition, boundary)
    
    // Create the uniform buffer
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(vector_float2), options: .CPUCacheModeDefaultCache)
    }
    
    // Copy latest arguments
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(vector_float2))
    
    // Set the buffer in the argument table
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
    super.init(functionName: "selectSelector")
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
