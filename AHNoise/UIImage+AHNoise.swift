//
//  UIImage+AHNoise.swift
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit

func AHNReleaseDataCallback(info: UnsafeMutablePointer<Void>, data: UnsafePointer<Void>, size: Int){
  free(UnsafeMutablePointer(data))
}

extension UIImage{
  
  ///Converts the input `MTLTexture` into a UIImage.
  static func imageWithMTLTexture(texture: MTLTexture) -> UIImage{
    assert(texture.pixelFormat == .RGBA8Unorm, "Pixel format of texture must be MTLPixelFormatBGRA8Unorm to create UIImage")
    
    let imageByteCount: size_t = texture.width * texture.height * 4
    let imageBytes = malloc(imageByteCount)
    let bytesPerRow = texture.width * 4
    
    let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
    texture.getBytes(imageBytes, bytesPerRow: bytesPerRow, fromRegion: region, mipmapLevel: 0)
    
    let provider = CGDataProviderCreateWithData(nil, imageBytes, imageByteCount, AHNReleaseDataCallback)
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let colourSpaceRef = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue), CGBitmapInfo.ByteOrder32Big]
    let renderingIntent: CGColorRenderingIntent = .RenderingIntentDefault
    
    let imageRef = CGImageCreate(
      texture.width,
      texture.height,
      bitsPerComponent,
      bitsPerPixel,
      bytesPerRow,
      colourSpaceRef,
      bitmapInfo,
      provider,
      nil,
      false,
      renderingIntent)
    
    let image = UIImage(CGImage: imageRef!, scale: 0.0, orientation: UIImageOrientation.DownMirrored)
    return image
  }
}