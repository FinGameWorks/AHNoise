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
private struct AHNScaleCanvasProperties{
  var scale: vector_float4
  var oldSize: vector_int4
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and scales and repositions it in its texture.
 
 When initialising a new `AHNModifierScaleCanvas' you specify a new, immutable canvas size that the input can be repositioned in.
 
 The `xScale` and `yScale` (1.0, 1.0) properties allow you to stretch or shrink a texture within the new canvas, and the `xAnchor` and `yAnchor` (0.0,0.0 by default) properties allow you to move the bottom left hand corner of the input to reposition it within the new canvas. An anchor value of 0 leaves the input at the origin, whereas a value of 1.0 moves it to the other extreme of the canvas.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierScaleCanvas: NSObject, AHNTextureProvider {
  
  
  //MARK:- Properties
  
  
  ///The scales and anchors wrapped in a vector for communicating with the GPU.
  private var scale: vector_float4 = vector_float4(0, 0, 1, 1)
  
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU. This is recovered from the first `AHNGenerator` class that is encountered in the chain of classes.
  public var context: AHNContext
  
  
  
  ///The `MTLComputePipelineState` used to run the `Metal` compute kernel on the GPU.
  private let pipeline: MTLComputePipelineState
  
  
  
  ///The `MTLBuffer` used to transfer the constant values used by the compute kernel to the GPU.
  public var uniformBuffer: MTLBuffer?
  
  
  
  ///The `MTLTexture` that the compute kernel writes to as an output.
  internal var internalTexture: MTLTexture?
  
  
  
  /**
   The `MTLFunction` compute kernel that modifies the input `MTLTexture`s and writes the output to the `internalTexture` property.
   
   The function used is specific to each class.
   */
  private let kernelFunction: MTLFunction
  
  
  
  ///Indicates whether or not the `internalTexture` needs updating.
  internal var dirty: Bool
  
  
  
  ///The first input that will be combined with `provider2` using `selector` to provide the output.
  private var provider: AHNTextureProvider?
  
  
  
  ///The width of the new `MTLTexture`
  private var width: Int = 128
  
  
  
  ///The height of the new `MTLTexture`
  private var height: Int = 128
  
  
  
  ///The that will be modified to provide the output.
  public var input: AHNTextureProvider?{
    get{
      return provider
    }
    set{
      provider = newValue
      dirty = true
    }
  }
  
  
  
  ///The position along the horizontal axis of the bottom left corner of the input in the new canvas. Ranges from 0.0 for far left to 1.0 for far right, though values beyond this can be used. Default value is 0.0.
  public var xAnchor: Float{
    get{
      return scale.x
    }
    set{
      scale.x = newValue
      dirty = true
    }
  }
  
  
  
  ///The position along the vertical axis of the bottom left corner of the input in the new canvas. Ranges from 0.0 for the bottom to 1.0 for the top, though values beyond this can be used. Default value is 0.0.
  public var yAnchor: Float{
    get{
      return scale.y
    }
    set{
      scale.y = newValue
      dirty = true
    }
  }
  
  
  
  /// The scale of the input when inserted into the canvas. If an input had a width of 256, which is being resized to 512 with a scale of 0.5, the width of the input would be 128 in the canvas of 512. Default value is 1.0.
  public var xScale: Float{
    get{
      return scale.z
    }
    set{
      scale.z = newValue
      dirty = true
    }
  }
  
  
  
  /// The scale of the input when inserted into the canvas. If an input had a height of 256, which is being resized to 512 with a scale of 0.5, the height of the input would be 128 in the canvas of 512. Default value is 1.0.
  public var yScale: Float{
    get{
      return scale.w
    }
    set{
      scale.w = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierScaleCanvas` object.
   
   - parameter input: The input to insert into the new canvas.
   - parameter newSize: The size of the output texture in pixels. Note that it will be rounded to factors of 8.
   */
  public init(input: AHNTextureProvider, newSize: CGSize){
    var input = input
    
    context = input.context
    let functionName = "scaleCanvasModifier"
    
    guard let kernelFunction = context.library.newFunctionWithName(functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.newComputePipelineStateWithFunction(kernelFunction)
    }catch{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).")
    }
    
    dirty = true
    provider = input
    super.init()
    width = Int(newSize.width)
    height = Int(newSize.height)
  }
  

  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier`. This should never be called directly.
  public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = AHNScaleCanvasProperties(scale: scale, oldSize: vector_int4(Int32(provider!.textureSize().width), Int32(provider!.textureSize().height),0,0))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.newBufferWithLength(sizeof(AHNScaleCanvasProperties), options: .CPUCacheModeDefaultCache)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, sizeof(AHNScaleCanvasProperties))
    
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
    if internalTexture!.width != width || internalTexture!.height != height{
      newInternalTexture()
    }
    
    let threadGroupsCount = MTLSizeMake(8, 8, 1)
    let threadGroups = MTLSizeMake(width / threadGroupsCount.width, height / threadGroupsCount.height, 1)
    
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
  private func newInternalTexture(){
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: width, height: height, mipmapped: false)
    internalTexture = context.device.newTextureWithDescriptor(textureDescriptor)
  }
  

  
  ///- returns: The updated output `MTLTexture` for this module.
  public func texture() -> MTLTexture{
    if isDirty(){
      updateTexture()
    }
    return internalTexture!
  }
  
  
  
  ///- returns: The MTLSize of the the output `MTLTexture`. If no size has been explicitly set, the default value returned is `128x128` pixels.
  public func textureSize() -> MTLSize{
    return MTLSizeMake(width, height, 1)
  }
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to the `AHNModifier`. This is taken from the `input`. If there is no `input`, returns `nil`.
  public func textureProvider() -> AHNTextureProvider?{
    return provider
  }
  
  
  
  ///- returns: `False` if the input and the `internalTexture` do not need updating.
  public func isDirty() -> Bool {
    if let p = provider{
      return p.isDirty()
    }else{
      return dirty
    }
  }
}
