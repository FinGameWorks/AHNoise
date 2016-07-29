//
//  AHNTextureProvider.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import UIKit
import simd



// MARK:- AHNTextureProvider


///Implemented by classes that output an `MTLTexture`. Provides references to textures and helper functions.
public protocol AHNTextureProvider: class{
  
  
  /**
   - returns: The updated output `MTLTexture` for the `AHNTextureProvider`.
   */
  func texture() -> MTLTexture?
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to this `AHNTextureProvider`. If there is no input, returns `nil`.
  func textureProvider() -> AHNTextureProvider?
  
  
  
  ///- returns: A UIImage created from the output `MTLTexture` provided by the `texture()` function.
  func uiImage() -> UIImage?
  
  
  
  ///- returns: The MTLSize of the the output `MTLTexture`. If no size has been explicitly set, the default value returned is `128x128` pixels.
  func textureSize() -> MTLSize
  
  
  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  func updateTexture()
  
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU.
  var context: AHNContext {get set}
  
  
  
  ///- returns: Returns `true` if the output `MTLTexture` needs updating to represent the current `AHNTextureProvider` properties.
  func isDirty() -> Bool
  
  
  
  
  var dirty: Bool {get set}
  
  
  
  ///Returns a new `AHNTextureProvider` object.
  init()
  
  
  
  func isKindOfClass(aClass: AnyClass) -> Bool
  
  
  
  func valueForKey(key: String) -> AnyObject?
  
  
  
  func setValue(value: AnyObject?, forKey key: String)
  
  
  
  
  
  ///- returns: `True` if the object has enough inputs to provide an output.
  func canUpdate() -> Bool
  
  
  func clone() -> AHNTextureProvider
  
  
  func code() -> String
  
  
  var modName: String { get set }
  
  
  /**
   Returns the greyscale values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return greyscale values between `0.0 - 1.0`.
   - returns: The greyscale values between `0.0 - 1.0` for the specified pixel locations.
   */
  func greyscaleValuesAtPositions(positions: [CGPoint]) -> [Float]
  
  
  /**
   Returns the colour values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return colour values for red, green, blue and alpha between `0.0 - 1.0`.
   - returns: The colour values between `0.0 - 1.0` for the specified pixel locations.
   */
  func colourValuesAtPositions(positions: [CGPoint]) -> [(red: Float, green: Float, blue: Float, alpha: Float)]

  
  ///- returns: All points in the texture, use this as the input parameter for `colourValuesAtPositions` or `greyscaleValuesAtPositions` to return the values for the whole texture.
  func allTexturePositions() -> [CGPoint]
}












// MARK:- Default AHNTextureProvider Implementation


extension AHNTextureProvider{
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to this `AHNTextureProvider`. If there is no input, returns `nil`.
  public func textureProvider() -> AHNTextureProvider?{
    return nil
  }
  
  
  
  ///- returns: A UIImage created from the output `MTLTexture` provided by the `texture()` function.
  public func uiImage() -> UIImage?{
    if !canUpdate(){ return nil }
    guard let texture = texture() else { return nil }
    return UIImage.imageWithMTLTexture(texture)
  }
  
  
  
  // Module name in title case
  public func moduleName() -> String{
    var str = "\(Mirror(reflecting: self).subjectType)"
    
    if str.hasPrefix("AHN"){
      for _ in 0..<3{
        str.removeAtIndex(str.startIndex)
      }
    }
    
    str = str.titleCase()
    var retVal = ""
    let split = str.componentsSeparatedByString(" ")
    for i in 0..<split.count{
      if i != 0 { retVal += " " }
      retVal += split[(split.count-1)-i]
    }
    
    return retVal
  }
  
  
  public func clone() -> AHNTextureProvider{
    if let colour = self as? AHNModifierColour{
      return colour.clone()
    }
    let clone = self.dynamicType.init()
    guard let mod = self as? Moduleable, let obj = self as? NSObject , objclone = clone as? NSObject else { return clone }
    
    for property in mod.allowableControls{
      objclone.setValue(obj.valueForKey(property), forKey: property)
    }
    return clone
  }
  
  
  public func code() -> String{
    
    guard let obj = self as? NSObject else { return "error" }
    
    // Duplicate for testing against
    let duplicate = self.dynamicType.init()
    guard let duplicateObj = duplicate as? NSObject else { return "error" }
    var retString = ""
    let className = obj.className
    
    // Add input code
    if let generator = self as? AHNGenerator{
      if let provider = generator.xoffsetInput{
        retString += provider.code()
      }
      if let provider2 = generator.yoffsetInput{
        retString += provider2.code()
      }
    }
    if let modifier = self as? AHNModifier{
      if let provider = modifier.provider{
        retString += provider.code()
      }
    }
    if let modifier = self as? AHNModifierMapNormal{
      if let provider = modifier.provider{
        retString += provider.code()
      }
    }
    if let modifier = self as? AHNModifierScaleCanvas{
      if let provider = modifier.provider{
        retString += provider.code()
      }
    }
    if let combiner = self as? AHNCombiner{
      if let provider = combiner.provider{
        retString += provider.code()
      }
      if let provider2 = combiner.provider2{
        retString += provider2.code()
      }
    }
    if let selector = self as? AHNSelector{
      if let provider = selector.provider{
        retString += provider.code()
      }
      if let provider2 = selector.provider2{
        retString += provider2.code()
      }
      if let select = selector.selector{
        retString += select.code()
      }
    }
    
    // Add init
    retString += "let \(modName) = \(className)()\n"
    if let mod = self as? Moduleable {
      
      // Set providers
      if let generator = self as? AHNGenerator{
        if let provider = generator.xoffsetInput{
          retString += "\(modName).xoffsetInput = \(provider.modName)\n"
        }
        if let provider = generator.yoffsetInput{
          retString += "\(modName).yoffsetInput = \(provider.modName)\n"
        }
      }
      if let modifier = self as? AHNModifier{
        if let provider = modifier.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
      }
      if let modifier = self as? AHNModifierMapNormal{
        if let provider = modifier.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
      }
      
      if let modifier = self as? AHNModifierScaleCanvas{
        if let provider = modifier.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
      }
      if let combiner = self as? AHNCombiner{
        if let provider = combiner.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
        if let provider2 = combiner.provider2{
          retString += "\(modName).provider2 = \(provider2.modName)\n"
        }
      }
      if let selector = self as? AHNSelector{
        if let provider = selector.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
        if let provider2 = selector.provider2{
          retString += "\(modName).provider2 = \(provider2.modName)\n"
        }
        if let select = selector.selector{
          retString += "\(modName).selector = \(select.modName)\n"
        }
      }
      
      // Set the rest of the properties
      for property in mod.allowableControls{
        
        // Get the property for the object and default duplicate
        let val = obj.valueForKey(property)
        let duplicateVal = duplicateObj.valueForKey(property)
        
        // Convert to string
        var strVal = "\(val)"
        let duplicateStrVal = "\(duplicateVal)"
        
        // If they are the same then no need to set value
        if strVal == duplicateStrVal { continue }
        
        // String for Booleans
        let booleanProperties = ["seamless", " sitesVisible", "cutEdges", "normalise"]
        if booleanProperties.contains(property){
          strVal = val as! Int == 1 ? "true" : "false"
        }
        
        if strVal.containsString("Optional"){
          strVal = strVal.stringByReplacingOccurrencesOfString("Optional(", withString: "")
          strVal = strVal.stringByReplacingOccurrencesOfString(")", withString: "")
        }
        retString += "\(modName).\(property) = \(strVal)\n"
      }
    }else{
      
      // For colour coding
      if let colour = self as? AHNModifierColour{
        
        // Set provider
        if let provider = colour.provider{
          retString += "\(modName).provider = \(provider.modName)\n"
        }
        
        // Empty string to enter tuple code into
        var coloursTupleString = "["
        
        // For colour components
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        for (i, tuple) in colour.colours.enumerate(){
          if i != 0{
            coloursTupleString += ", "
          }
          tuple.colour.getRed(&r, green: &g, blue: &b, alpha: &a)
          coloursTupleString += "(colour: UIColor(red: \(r), green: \(g), blue: \(b), alpha: 1.0), position: \(tuple.position), intensity: \(tuple.intensity))"
        }
        coloursTupleString += "]"
        retString += "\(modName).colours = \(coloursTupleString)\n"
      }
    }
    return retString + "\n"
  }
  
  
  
  
  /**
   Returns the colour values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return greyscale values between `0.0 - 1.0`.
   - returns: The greyscale values between `0.0 - 1.0` for the specified pixel locations.
   */
  public func greyscaleValuesAtPositions(positions: [CGPoint]) -> [Float]{
    let size = textureSize()
    let pixelCount = size.width * size.height
    var array = [UInt8](count: pixelCount*4, repeatedValue: 0)
    let region = MTLRegionMake2D(0, 0, size.width, size.height)
    texture()?.getBytes(&array, bytesPerRow: size.width * strideof(UInt8)*4, fromRegion: region, mipmapLevel: 0)
    
    var returnArray = [Float](count: positions.count, repeatedValue: 0)
    for (i, position) in positions.enumerate(){
      if Int(position.x) >= size.width || Int(position.y) >= size.height{
        print("AHNoise: ERROR - Unable to get value for \(position) as it is outside the texture bounds")
        continue
      }
      let index = (Int(position.x) + (Int(position.y) * size.width)) * 4
      returnArray[i] = Float(array[index])/255
    }
    return returnArray
  }
  
  
  
  /**
   Returns the colour values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return colour values for red, green, blue and alpha between `0.0 - 1.0`.
   - returns: The colour values between `0.0 - 1.0` for the specified pixel locations.
   */
  public func colourValuesAtPositions(positions: [CGPoint]) -> [(red: Float, green: Float, blue: Float, alpha: Float)]{
    let size = textureSize()
    let pixelCount = size.width * size.height
    var array = [UInt8](count: pixelCount*4, repeatedValue: 0)
    let region = MTLRegionMake2D(0, 0, size.width, size.height)
    texture()?.getBytes(&array, bytesPerRow: size.width * strideof(UInt8)*4, fromRegion: region, mipmapLevel: 0)
    
    var returnArray = [(red: Float, green: Float, blue: Float, alpha: Float)](count: positions.count, repeatedValue: (0,0,0,0))
    for (i, position) in positions.enumerate(){
      if Int(position.x) >= size.width || Int(position.y) >= size.height{
        print("AHNoise: ERROR - Unable to get value for \(position) at index \(i) as it is outside the texture bounds")
        continue
      }
      let index = (Int(position.x) + (Int(position.y) * size.width)) * 4
      let r = Float(array[index])/255
      let g = Float(array[index+1])/255
      let b = Float(array[index+2])/255
      let a = Float(array[index+3])/255
      returnArray[i] = (red: r, green: g, blue: b, alpha: a)
    }
    return returnArray
  }


  
  ///- returns: All points in the texture, use this as the input parameter for `colourValuesAtPositions` or `greyscaleValuesAtPositions` to return the values for the whole texture.
  public func allTexturePositions() -> [CGPoint]{
    let size = textureSize()
    var array: [CGPoint] = []
    for i in 0..<size.width {
      for j in 0..<size.height {
        array.append(CGPointMake(CGFloat(j), CGFloat(i)))
      }
    }
    return array
  }
}

