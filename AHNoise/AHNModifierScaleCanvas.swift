//
//  AHNModifierScaleCanvas.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
struct AHNScaleCanvasProperties{
  var scale: vector_float4
  var oldSize: vector_int4
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and scales and repositions it in its texture.
 
 The `xScale` and `yScale` (`1.0, 1.0` by default) properties allow you to stretch or shrink a texture within the new canvas, and the `xAnchor` and `yAnchor` (`0.0,0.0` by default) properties allow you to move the bottom left hand corner of the input to reposition it within the new canvas. An anchor value of `0.0` leaves the input at the origin, whereas a value of `1.0` moves it to the other extreme of the canvas.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierScaleCanvas: NSObject, AHNTextureProvider {
  
  
  //MARK:- Properties
  
  var allowableControls: [String] = ["textureWidth", "textureHeight", "xAnchor", "yAnchor", "xScale", "yScale"]
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU. This is recovered from the first `AHNGenerator` class that is encountered in the chain of classes.
  public var context: AHNContext
  
  
  
  ///The `MTLComputePipelineState` used to run the `Metal` compute kernel on the GPU.
  let pipeline: MTLComputePipelineState
  
  
  
  ///The `MTLBuffer` used to transfer the constant values used by the compute kernel to the GPU.
  public var uniformBuffer: MTLBuffer?
  
  
  
  ///The `MTLTexture` that the compute kernel writes to as an output.
  var internalTexture: MTLTexture?
  
  
  
  /**
   The `MTLFunction` compute kernel that modifies the input `MTLTexture`s and writes the output to the `internalTexture` property.
   
   The function used is specific to each class.
   */
  let kernelFunction: MTLFunction
  
  
  
  ///Indicates whether or not the `internalTexture` needs updating.
  public var dirty: Bool = true
  
  
  
  ///The input that will be modified using to provide the output.
  public var provider: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The width of the new `MTLTexture`
  public var textureWidth: Int = 128{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The height of the new `MTLTexture`
  public var textureHeight: Int = 128{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the horizontal axis of the bottom left corner of the input in the new canvas. Ranges from `0.0` for far left to `1.0` for far right, though values beyond this can be used. Default value is `0.0`.
  public var xAnchor: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the vertical axis of the bottom left corner of the input in the new canvas. Ranges from `0.0` for the bottom to `1.0` for the top, though values beyond this can be used. Default value is `0.0`.
  public var yAnchor: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The scale of the input when inserted into the canvas. If an input had a width of `256`, which is being resized to `512` with a scale of `0.5`, the width of the input would be `128` in the canvas of `512`. Default value is `1.0`.
  public var xScale: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The scale of the input when inserted into the canvas. If an input had a height of `256`, which is being resized to `512` with a scale of `0.5`, the height of the input would be `128` in the canvas of `512`. Default value is `1.0`.
  public var yScale: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  public var modName: String = ""
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  override public required init(){
    context = AHNContext.SharedContext
    let functionName = "scaleCanvasModifier"
    
    guard let kernelFunction = context.library.newFunctionWithName(functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.newComputePipelineStateWithFunction(kernelFunction)
    }catch{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).\n\(error)")
    }
    super.init()
  }

  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier`. This should never be called directly.
  public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = AHNScaleCanvasProperties(scale: vector_float4(xAnchor, yAnchor, xScale, yScale), oldSize: vector_int4(Int32(provider!.textureSize().width), Int32(provider!.textureSize().height),0,0))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(strideof(AHNScaleCanvasProperties), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, strideof(AHNScaleCanvasProperties))
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Texture Functions
  
  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  public func updateTexture(){
    if provider == nil {return}

    if internalTexture == nil{
      newInternalTexture()
    }
    if internalTexture!.width != textureWidth || internalTexture!.height != textureHeight{
      newInternalTexture()
    }
    
    let threadGroupsCount = MTLSizeMake(8, 8, 1)
    let threadGroups = MTLSizeMake(textureWidth / threadGroupsCount.width, textureHeight / threadGroupsCount.height, 1)
    
    let commandBuffer = context.commandQueue.commandBuffer()
    
    let commandEncoder = commandBuffer.computeCommandEncoder()
    commandEncoder.setComputePipelineState(pipeline)
    commandEncoder.setTexture(provider!.texture(), atIndex: 0)
    commandEncoder.setTexture(internalTexture, atIndex: 1)
    configureArgumentTableWithCommandencoder(commandEncoder)
    commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupsCount)
    commandEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    dirty = false
  }
  
  
  
  ///Create a new `internalTexture` for the first time or whenever the texture is resized.
  func newInternalTexture(){
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: textureWidth, height: textureHeight, mipmapped: false)
    internalTexture = context.device.newTextureWithDescriptor(textureDescriptor)
  }
  

  
  ///- returns: The updated output `MTLTexture` for this module.
  public func texture() -> MTLTexture?{
    if isDirty(){
      updateTexture()
    }
    return internalTexture
  }
  
  
  
  ///- returns: The MTLSize of the the output `MTLTexture`. If no size has been explicitly set, the default value returned is `128x128` pixels.
  public func textureSize() -> MTLSize{
    return MTLSizeMake(textureWidth, textureHeight, 1)
  }
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to the `AHNModifier`. This is taken from the `input`. If there is no `input`, returns `nil`.
  public func textureProvider() -> AHNTextureProvider?{
    return provider
  }
  
  
  
  ///- returns: `False` if the input and the `internalTexture` do not need updating.
  public func isDirty() -> Bool {
    if let p = provider{
      return p.isDirty() || dirty
    }else{
      return dirty
    }
  }
  
  
  
  ///-returns: `False` if the `provider` is not set.
  public func canUpdate() -> Bool {
    return provider != nil
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
    context = AHNContext.SharedContext
    let functionName = "scaleCanvasModifier"
    
    guard let kernelFunction = context.library.newFunctionWithName(functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.newComputePipelineStateWithFunction(kernelFunction)
    }catch{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).\n\(error)")
    }
    super.init()
    
    
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
