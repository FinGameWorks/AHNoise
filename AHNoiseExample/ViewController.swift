//
//  ViewController.swift
//  AHNoiseExample
//
//  Created by Andrew Heard on 02/06/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Creates a wood effect
    let simplex = AHNGeneratorSimplex()
    simplex.textureWidth = 1024
    simplex.textureHeight = 1024
    simplex.octaves = 2
    simplex.frequency = 4
    
    let loop = AHNModifierLoop()
    loop.provider = simplex
    loop.boundary = 0.5
    loop.normalise = true
    
    let shift = AHNModifierScaleBias()
    shift.provider = loop
    shift.scale = 0.6
    shift.bias = 0.4
    

    // Create the grain
    let grain = AHNGeneratorSimplex()
    grain.textureWidth = 1024
    grain.textureHeight = 1024
    grain.frequency = 100
    
    let stretch = AHNModifierStretch()
    stretch.provider = grain
    stretch.yFactor = 30
    
    
    // Combine them
    let multiply = AHNCombinerMultiply()
    multiply.provider = shift
    multiply.provider2 = stretch
    
    // Make a brown constant colour and add it
    let brown = AHNGeneratorConstant()
    brown.textureWidth = 1024
    brown.textureHeight = 1024
    brown.red = 0.6
    brown.green = 0.4
    brown.blue = 0.3
    
    let combine = AHNCombinerMultiply()
    combine.provider = brown
    combine.provider2 = multiply
    
    let stretch2 = AHNModifierStretch()
    stretch2.provider = combine
    stretch2.yFactor = 4
    
    let imageView = UIImageView(frame: view.bounds)
    view.addSubview(imageView)
    imageView.image = stretch2.uiImage()
  }
}

