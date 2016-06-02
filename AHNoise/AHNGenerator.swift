//
//  AHNGenerator.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///A struct used to specify the origin of the generated noise in noise space.
public struct AHNPosition {
  var x: Float = 1
  var y: Float = 1
  
  init(x: Float, y: Float){
    self.x = x
    self.y = y
  }
}


///Struct used to communicate properties to the GPU.
internal struct SimplexInputs {
  var pos: vector_float2
  var octaves: Int32
  var persistance: Float
  var frequency: Float
  var lacunarity: Float
  var zValue: Float
  var wValue: Float
  var use4D: Int32
  var sphereMap: Int32
  var seamless: Int
}


/**
 The general class to generate cohesive noise outputs. This class is not instantiated directly, but is used by various subclasses.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNGenerator: NSObject, AHNTextureProvider {
  
  
  // MARK:- Properties
  public var context: AHNContext
  internal var uniformBuffer: MTLBuffer?
  private let pipeline: MTLComputePipelineState
  private var internalTexture: MTLTexture?
  private let kernelFunction: MTLFunction
  internal var dirty: Bool
  internal var use4D: Int = 0
  internal var sphereMap: Int = 0
  internal var seamless: Int = 0
  private var _octaves: Int = 6
  private var _persistance: Float = 0.5
  private var _frequency: Float = 1.0
  private var _lacunarity: Float = 2.0
  private var width: Int = 128
  private var height: Int = 128
  private var pos: AHNPosition = AHNPosition(x: 1, y: 1)
  private var z: Float = 1
  private var w: Float = 1
  private var timeDependant = false
  private var timer: NSTimer?
  
  
  
  ///The width (in pixels) of the output noise texture.
  public var textureWidth: Int{
    get{
      return width
    }
    set{
      if newValue % 8 != 0 { print("AHNoise: WARNING - Texture width will be rounded to a factor of 8.") }
      width = newValue
      dirty = true
    }
  }
  
  
  
  ///The height (in pixels) of the output noise texture.
  public var textureHeight: Int{
    get{
      return height
    }
    set{
      if newValue % 8 != 0 { print("AHNoise: WARNING - Texture height will be rounded to a factor of 8.") }
      height = newValue
      dirty = true
    }
  }
  
  
  
  ///The origin of the noise in noise space. Changing this slightly will make the noise texture appear to move.
  ///
  ///Default is (1,1)
  public var position: AHNPosition{
    get{
      return pos
    }
    set{
      pos = newValue
      dirty = true
    }
  }
  
  
  
  ///The value for the third dimension when calculating the noise.
  ///
  ///Default is 1.0.
  public var zValue: Float{
    get{
      return z
    }
    set{
      z = newValue
      dirty = true
    }
  }
  
  
  
  ///The value for the fourth dimension when calculating 4D noise. This is mostly only used to create spherically mapped or seamless textures.
  ///
  ///Default is 1.0.
  public var wValue: Float{
    get{
      return w
    }
    set{
      w = newValue
      dirty = true
    }
  }
  
  
  
  /**
   The number of `octaves` to use in the texture. Each `octave` is calculated with a different amplitude (altered by the `persistance` property) and `frequency` (altered by the `lacunarity` property).
   
   Each `octave` is calculated and then combined to produce the final value.
   
   Higher values (8) produce more detailed noise, where as lower values produce smoother noise. Higher values have a performance impact.
   
   Default is 6.
   */
  public var octaves: Int{
    get{
      return _octaves
    }
    set{
      _octaves = newValue
      dirty = true
    }
  }
  
  
  
  /**
   Varies the amplitude every `octave`. The amplitude is multipled by the `persisance` for each `octave`. Generally values less than 1.0 are used.
   
   For example an initial amplitude of 1.0 (fixed) and a `persistance` of 0.5 for 4 octaves would produce an amplitude of 1.0, 0.5, 0.25 and 0.125 respectively for each octave.
   
   Default is 0.5.
   */
  public var persistance: Float{
    get{
      return _persistance
    }
    set{
      _persistance = newValue
      dirty = true
    }
  }
  
  
  
  /**
   The frequency used when calculating the noise. Higher values produce more dense noise.
   
   The `frequency` is multiplied by the `lacunarity` property each octave.
   
   Default is 1.0.
   */
  public var frequency: Float{
    get{
      return _frequency
    }
    set{
      _frequency = newValue
      dirty = true
    }
  }
  
  
  
  /**
   Varies the `frequency` every `octave`. The `frequency` is multipled by the `lacunarity` for each `octave`. Generally values less than 1.0 are used.
   
   For example an initial `frequency` of 1.0 and a `lacunarity` of 0.5 for 4 octaves would produce a `frequency` of 1.0, 0.5, 0.25 and 0.125 respectively for each octave.
   
   Default is 2.0.
   */
  public var lacunarity: Float{
    get{
      return _lacunarity
    }
    set{
      _lacunarity = newValue
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNGenerator` object.
   
   To be called when instantiating a subclass.

   - parameter functionName: The name of the kernel function that this generator will use to create noise.
   - parameter context: The `AHNContext` object that will be used to create the buffers and command encoders required.
   - parameter textureWidth: The desired width of the output texture in pixels.
   - parameter textureHeight: The desired height of the output texture in pixels.
   - parameter use4DNoise: Switches the kernel to use 4D Simplex noise instead of 3D. Useful for when an extra dimension is required, for example to create volumetric noise or seamless noise. Has a higher resource requirement.
   - parameter mapForSphere: Toggles whether to map the output texture to wrap suitably onto a UV sphere geometry. Implicitly uses 4D noise and is seamless.
   - parameter makeSeamless: Toggles whether to make the texture seamless. The output will be tileable seamlessly with no mirroring. Implicitly uses 4D noise.
  */
  public init(functionName: String, context: AHNContext, textureWidth width: Int, textureHeight height: Int, use4DNoise: Bool, mapForSphere: Bool, makeSeamless: Bool){
    self.context = context
    use4D = use4DNoise || mapForSphere || makeSeamless ? 1 : 0
    sphereMap = mapForSphere ? 1 : 0
    seamless = makeSeamless ? 1 : 0
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
    super.init()
    
    textureWidth = width
    textureHeight = height
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Configure Uniforms
  
  
  /**
   Override this method in subclasses to configure a uniform buffer to be sent to the kernel.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` used to run the kernel. This can be used to lazily create a buffer of data and add it to the argument table. Any buffer index can be used without affecting the rest of this class.
  */
  public func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder){
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Texture Functions

  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  public func updateTexture(){
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
    commandEncoder.setTexture(internalTexture, atIndex: 0)
    configureArgumentTableWithCommandencoder(commandEncoder)
    commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupsCount)
    commandEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    
    dirty = false
  }
  
  
  
  ///Create a new `internalTexture` for the first time or whenever the texture is resized.
  private func newInternalTexture(){
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: textureWidth, height: textureHeight, mipmapped: false)
    internalTexture = context.device.newTextureWithDescriptor(textureDescriptor)
  }
  
  
  
  // Texture Provider
  ///- returns: The updated output `MTLTexture` for this module.
  public func texture() -> MTLTexture{
    if isDirty(){
      updateTexture()
    }
    return internalTexture!
  }
  
  
  
  ///- returns: The size of the output `MTLTexture`.
  public func textureSize() -> MTLSize{
    return MTLSizeMake(textureWidth, textureHeight, 1)
  }
  
  
  
  ///- returns: A boolean value indicating whether or not the texture need updating to include updated properties.
  public func isDirty() -> Bool {
    return dirty
  }
}
