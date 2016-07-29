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
    
    let loop = AHNModifierLoop(input: simplex, loopEvery: 0.2)
    loop.normalise = true
    
    let shift = AHNModifierScaleBias(input: loop, scale: 0.6, bias: 0.4)
    
    
    // Create the grain
    let grain = AHNGeneratorSimplex(context: context, textureWidth: 1024, textureHeight: 1024, use4DNoise: false, mapForSphere: false, makeSeamless: false)
    grain.frequency = 100
    
    let stretch = AHNModifierStretch(input: grain, xStretchFactor: 1, yStretchFactor: 70)
    
    
    // Combine them
    let multiply = AHNCombinerMultiply(input1: shift, input2: stretch)
    
    // Make a brown constant colour and add it
    let brown = AHNGeneratorConstant(context: context, textureWidth: 1024, textureHeight: 1024, red: 0.6, green: 0.4, blue: 0.3)
    
    let combine = AHNCombinerMultiply(input1: brown, input2: multiply)
    
    let stretch2 = AHNModifierStretch(input: combine, xStretchFactor: 1, yStretchFactor: 4	)
    
    let imageView = UIImageView(frame: view.bounds)
    view.addSubview(imageView)
    imageView.image = stretch2.uiImage()
  }
}

