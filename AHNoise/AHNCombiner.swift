//
//  AHNCombiner.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 The general class used to combine two input `AHNTextureProvider`s and write the result to an output. This class is not instantiated directly, but is used by various subclasses.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNCombiner: NSObject, AHNTextureProvider {
  
  
  // MARK:- Properties
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU. This is recovered from the first `AHNGenerator` class that is encountered in the chain of classes.
  public var context: AHNContext
  
  
  
  ///The `MTLComputePipelineState` used to run the `Metal` compute kernel on the GPU.
  private let pipeline: MTLComputePipelineState
  
  
  
  ///The `MTLBuffer` used to transfer the constant values used by the compute kernel to the GPU.
  public var uniformBuffer: MTLBuffer?
  
  
  
  ///The `MTLTexture` that the compute kernel writes to as an output.
  private var internalTexture: MTLTexture?
  
  
  
  /**
   The `MTLFunction` compute kernel that modifies the input `MTLTexture`s and writes the output to the `internalTexture` property.
   
   The function used is specific to each class.
   */
  private let kernelFunction: MTLFunction
  
  
  
  ///Indicates whether or not the `internalTexture` needs updating.
  internal var dirty: Bool
  
  
  
  ///The first input that will be combined with `provider2` to provide the output.
  private var provider: AHNTextureProvider?
  
  
  
  ///The second input that will be combined with `provider` to provide the output.
  private var provider2: AHNTextureProvider?
  
  
  
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
  
  
  
  ///The first input that will be combined with `provider2` to provide the output.
  public var input1: AHNTextureProvider?{
    get{
      return provider
    }
    set{
      provider = newValue
      dirty = true
    }
  }
  
  
  
  ///The second input that will be combined with `provider` to provide the output.
  public var input2: AHNTextureProvider?{
    get{
      return provider2
    }
    set{
      provider2 = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNCombiner` object.
   
   To be called when instantiating a subclass.
   
   - parameter functionName: The name of the kernel function that this generator will use to combine inputs.
   - parameter input1: The first input that will be combined with `input2` to provide the output.
   - parameter input2: The second input that will be combined with `input1` to provide the output.
   */
  public init(functionName: String, input1: AHNTextureProvider, input2: AHNTextureProvider){
    
    // Ensure input textures have the same size
    assert(input1.textureSize().width == input2.textureSize().width, "Inputs must have the same texture width")
    assert(input1.textureSize().height == input2.textureSize().height, "Inputs must have the same texture height")

    // Gather the context to use from the first input
    context = input1.context
    
    // Load the kernel function and compute pipeline state
    guard let kernelFunction = context.library.newFunctionWithName(functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.newComputePipelineStateWithFunction(kernelFunction)
    }catch{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).")
    }
    
    // Set the texture to update
    dirty = true
    
    provider = input1
    provider2 = input2
    super.init()
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Configure Uniforms

  
  /**
   This function is overridden by subclasses to  write class specific variables to the `uniformBuffer`.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` that can be used to encode the `uniformBuffer` for use in the compute `kernelFunction`.
   */
  public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder){
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Texture Functions
  
  
  /**
   Override this method in subclasses to configure a uniform buffer to be sent to the kernel.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` used to run the kernel. This can be used to lazily create a buffer of data and add it to the argument table. Any buffer index can be used without affecting the rest of this class.
   */
  public func updateTexture(){
    guard let provider1 = provider, provider2 = provider2 else { return }

    // Create the internalTexture if it equals nil or is the wrong size.
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
    commandEncoder.setTexture(provider1.texture(), atIndex: 0)
    commandEncoder.setTexture(provider2.texture(), atIndex: 1)
    commandEncoder.setTexture(internalTexture, atIndex: 2)
    
    // Encode the uniform buffer
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

  
  
  ///- returns: The updated output `MTLTexture` for the `AHNCombiner`.
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
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to the `AHNCombiner`. This is taken from `input1`. If there is no input, returns `nil`.
  public func textureProvider() -> AHNTextureProvider?{
    return provider
  }
  
  
  
  ///- returns: `False` if both inputs and the `internalTexture` do not need updating.
  public func isDirty() -> Bool {
    if let p = provider{
      return p.isDirty() || dirty
    }else{
      return dirty
    }
  }
}
