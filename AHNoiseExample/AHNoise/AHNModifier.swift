//
//  AHNModifier.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 The general class to modify the outputs of any class that adheres to the `AHNTextureProvider` protocol. This class is not instantiated directly, but is used by various subclasses.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifier: NSObject, AHNTextureProvider {
  
  
  // MARK:- Properties
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

  
  
  ///Indicates whether this modifier makes use of a `Metal Performance Shader`
  internal var usesMPS = false
  
  
  
  /**
   The width of the output `MTLTexure`.
   
   This is dictated by the width of the texture of the first input `AHNTextureProvider`. If there is no input, the default width is 128 pixels.
   */
  private var width: Int{
    get{
      return provider?.textureSize().width ?? 128
    }
  }
  
  
  
  /**
   The height of the output `MTLTexure`.
   
   This is dictated by the height of the texture of the first input `AHNTextureProvider`. If there is no input, the default height is 128 pixels.
   */
  private var height: Int{
    get{
      return provider?.textureSize().height ?? 128
    }
  }
  
  
  
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
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifier` object.
   
   To be called when instantiating a subclass.
   
   - parameter functionName: The name of the kernel function that this generator will use to modify the input texture.
   - parameter input: The `AHNTextureProvider` input that provides an `MTLTexture` for the kernel to modify.
   */
  public init(functionName: String, input: AHNTextureProvider){
    var input = input
    context = input.context
    
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
  }
  
  
  
  
  
  
  
  
  
  
  // MARK:- Configure Uniforms
  
  
  /**
   Override this method in subclasses to configure a uniform buffer to be sent to the kernel.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` used to run the kernel. This can be used to lazily create a buffer of data and add it to the argument table. Any buffer index can be used without affecting the rest of this class.
   */
  public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder){
  }
  
  
  
  /**
   Override this method in subclasses to configure a `Metal Performance Shader` to be used instead of a custom kernel.
   
   - parameter commandBuffer: The `MTLCommandBuffer` used to run the `Metal Performance Shader`.
   */
  public func addMetalPerformanceShaderToBuffer(commandBuffer: MTLCommandBuffer){
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
    
    // If an MPS is being used, encode it to the command buffer, else create a command encoder for a custom kernel
    if usesMPS{
      addMetalPerformanceShaderToBuffer(commandBuffer)
    }else{
      let commandEncoder = commandBuffer.computeCommandEncoder()
      commandEncoder.setComputePipelineState(pipeline)
      commandEncoder.setTexture(provider!.texture(), atIndex: 0)
      commandEncoder.setTexture(internalTexture, atIndex: 1)
      configureArgumentTableWithCommandencoder(commandEncoder)
      commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupsCount)
      commandEncoder.endEncoding()
    }
    
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
      return p.isDirty() || dirty
    }else{
      return dirty
    }
  }
}
