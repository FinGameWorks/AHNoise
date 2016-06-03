//
//  AHNModifierColour.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and colourises it.
 
 Applies a colouring to a specific range of values in a texture. Each `colour` has a position and an intensity dictating which values in the input texture are colourised and by how much.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
public class AHNModifierColour: AHNModifier {

  
  // MARK:- Properties
  
  
  ///A private buffer to contain colour positions.
  private var positionBuffer: MTLBuffer?
  
  
  
  ///A private buffer to contain the number of colours to use.
  private var countBuffer: MTLBuffer?
  
  
  
  ///A private buffer to contain the intensities of the colour application.
  private var intensityBuffer: MTLBuffer?
  
  
  
  ///A boolean to detect whether or not default colours are being used to avoid a crash
  private var defaultsUsed: Bool = false
  
  
  ///The number of colours in use
  private var colourCount: Int32{
    get{
      return Int32(_colours.count)
    }
  }
  
  
  
  ///The colour to apply to the input.
  private var _colours: [UIColor] = []
  
  
  
  ///The central position of the colouring range. Pixels with this value in the texture will output the `colour` due to a mix value of 1.0. Default value is 0.5.
  private var _positions: [Float] = []
  
  
  
  ///The intensities with which to apply the colours to in input.
  private var _intensities: [Float] = []
  
  
  ///The colour to apply to the input.  Must match the order of `positions` and `intensities`.
  public var colourInfo: [(colour: UIColor, position: Float, intensity: Float)]{
    get{
      var tuples: [(colour: UIColor, position: Float, intensity: Float)] = []
      for (i, colour) in _colours.enumerate(){
        let tuple = (colour, _positions[i], _intensities[i])
        tuples.append(tuple)
      }
      return tuples
    }
    set{
      var newValue = newValue
      defaultsUsed = false
      if newValue.count == 0{
        newValue = [(UIColor.whiteColor(), 0.5, 0.0)]
        defaultsUsed = true
      }
      var colours: [UIColor] = []
      var positions: [Float] = []
      var intensities: [Float] = []
      for tuple in newValue{
        colours.append(tuple.colour)
        positions.append(tuple.position)
        intensities.append(tuple.intensity)
      }
      _colours = colours
      _positions = positions
      _intensities = intensities
      dirty = true
      organiseColoursInOrder()
    }
  }
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNModifierColour` object.
   
   - parameter input: The input to colourise.
   - parameter colour: The `UIColor`s to apply to the input in the order that they will be applied.
   - parameter positions: The positions (between 0.0 - 1.0) of the colours to be applied. 0.0 being combined with dark inputs and 1.0 combined with light inputs.
   - parameter intensities: The intensity of the colour application for each colour. 1.0 replaces the input colour completely, and 0.0 has no effect with a linear blend in between.
   */
  public init(input: AHNTextureProvider, colourInfo colours: [(colour: UIColor, position: Float, intensity: Float)]){
    super.init(functionName: "colourModifier", input: input)
    colourInfo = colours
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  public override func configureArgumentTableWithCommandencoder(commandEncoder: MTLComputeCommandEncoder) {
    assert(_positions.count == _colours.count && _colours.count == _intensities.count, "AHNoise: ERROR - Number of colours to use must match the number of positions and intensities.")
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Convert UIColours to vector_float4
    var uniformsColours: [vector_float4] = []
    for colour in _colours{
      colour.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      uniformsColours.append(vector_float4(Float(red), Float(green), Float(blue), Float(alpha)))
    }
    
    // Create colour buffer and copy data
    var bufferSize = sizeof(vector_float4) * _colours.count
    if uniformBuffer == nil || uniformBuffer?.length != bufferSize{
      uniformBuffer = context.device.newBufferWithLength(bufferSize, options: .CPUCacheModeDefaultCache)
    }
    memcpy(uniformBuffer!.contents(), &uniformsColours, bufferSize)
    commandEncoder.setBuffer(uniformBuffer, offset: 0, atIndex: 0)
    
    // Create positions buffer and copy data
    bufferSize = sizeof(Float) * _positions.count
    if positionBuffer == nil || positionBuffer?.length != bufferSize{
      positionBuffer = context.device.newBufferWithLength(bufferSize, options: .CPUCacheModeDefaultCache)
    }
    memcpy(positionBuffer!.contents(), &_positions, bufferSize)
    commandEncoder.setBuffer(positionBuffer, offset: 0, atIndex: 1)
    
    // Create intensities buffer and copy data
    bufferSize = sizeof(Float) * _intensities.count
    if intensityBuffer == nil || intensityBuffer?.length != bufferSize{
      intensityBuffer = context.device.newBufferWithLength(bufferSize, options: .CPUCacheModeDefaultCache)
    }
    memcpy(intensityBuffer!.contents(), &_intensities, bufferSize)
    commandEncoder.setBuffer(intensityBuffer, offset: 0, atIndex: 2)
    
    // Create the colour count buffer and copy data
    bufferSize = sizeof(Float)
    if countBuffer == nil{
      countBuffer = context.device.newBufferWithLength(bufferSize, options: .CPUCacheModeDefaultCache)
    }
    var count = colourCount
    memcpy(countBuffer!.contents(), &count, bufferSize)
    commandEncoder.setBuffer(countBuffer, offset: 0, atIndex: 3)
  }








  // MARK:- Colour Handling
  
  
  ///Organise the colours, positions and intensities arrays.
  private func organiseColoursInOrder(){
    assert(_positions.count == _colours.count && _colours.count == _intensities.count, "AHNoise: ERROR - Number of colours to use must match the number of positions and intensities.")
    var tuples: [(colour: UIColor, position: Float, intensity: Float)] = []
    
    for (i, colour) in _colours.enumerate(){
      let tuple = (colour, _positions[i], _intensities[i])
      tuples.append(tuple)
    }
    
    tuples = tuples.sort({ $0.position < $1.position })
    
    var sortedColours: [UIColor] = []
    var sortedPositions: [Float] = []
    var sortedIntensities: [Float] = []
    for tuple in tuples{
      sortedColours.append(tuple.colour)
      sortedPositions.append(tuple.position)
      sortedIntensities.append(tuple.intensity)
    }
    
    _colours = sortedColours
    _positions = sortedPositions
    _intensities = sortedIntensities
  }
  
  
  ///Add a new colour, with corresponding position and intensity.
  public func addColour(colour: UIColor, position: Float, intensity: Float){
    if defaultsUsed{
      colourInfo = [(colour, position, intensity)]
    }else{
      colourInfo.append((colour, position, intensity))
    }
  }
  
  
  
  ///Remove all colours.
  public func removeAllColours(){
    colourInfo = []
  }
}