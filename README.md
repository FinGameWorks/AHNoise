# AHNoise
## A procedural, cohesive, modular noise library built using Metal and Swift

***

###Introduction
Cohesive, procedural noise can be used to add natural looking unevenness to a texture. This library provides the tools required to generate procedural noise and modify it all on the GPU using Metal and Swift. It is similar in functionality to Apple’s own `GameplayKit` noise framework released in iOS 10, as both have taken inspiration from the libnoise framework that has not been supported for some time now. There are some discrepancies between this framework and `GameplayKit`, most notably the extremely different outputs from the respective “Billow” generators and the lack of curve remapping. The only other major difference in capability is in the speed that a noise texture is generated. The `GameplayKit` noise generation can take a few seconds for a simple Perlin/Simplex texture at 512x512px, whereas this framework can calculate multiple textures a second as demonstrated in the Noise Studio App, built to demonstrate and act as a tool for using this noise library.

###Library Overview
Most of the classes in `AHNoise` will output a texture that can either be used as the input to another class, or converted into a `UIImage` for use. The only class that does not output a texture is `AHNContext`, which is a wrapper for the Metal classes used to communicate with the GPU. All other classes will output a texture by calling the `texture()` function. Most of the other classes will also allow an input texture to modify in some way. It is only `AHNGenerator` subclasses as well as the `AHNContext` class that have no input. `AHNModifiers` have one texture input and one texture output, `AHNCombiners` have two texture inputs and one texture output and `AHNSelectors` have three texture inputs and one texture output. Each subclass has various tools and properties to modify behaviour too.

All classes in this module are prefixed with “AHN”. This is then split into categories such as `AHNGenerator`, `AHNModifier`, `AHNCombiner` and `AHNSelector`. These are superclasses designed to be subclassed into usable modules such as `AHNGeneratorSimplex` or `AHNCombinerMultiply` etc. The idea being that by starting to type “AHN” you are a presented with a list of all classes which can then be narrowed down as you continue to type.

All texture generation and modification is carried out on the GPU. A module will populate its `texture()` property which can then be handed to another module which will then use it in its own GPU based calculations. This provides a very simple modular approach, though the downside is that when chaining together a large number of modules, texture memory is being copied to and from the GPU multiple times, which is not the most efficient means of creating a texture though it is a sacrifice made to enable the versatility of the framework.

The noise calculations output a value in the range -1.0 to 1.0. This is mapped to the RGB range 0.0 to 1.0 with 0.0 being black and 1.0 white. The only exception to this is the `AHNModifierAbsolute` class that performs its calculations before the range is remapped to enable the `abs()` function to have an effect.  Where colour is used, it is sometimes necessary to average the RGB components to greyscale in order to perform calculations, so it is advisable to carry out any colourising of textures at the end of module chains.


###How to Use
Chains must start with an `AHNGenerator` subclass to create the initial texture. These classes require input but output a texture, such as simplex noise.

    let simplex = AHNGeneratorSimplex()

The details of class properties are discussed in detail in the documentation.
With the fist noise module ready it can either be directly turned into a `UIImage`:

    let image = simplex.uiImage()

Otherwise it can be used as the input to another AHNoise module. For example it can have its values clamped:

    let clamp = AHNModifierClamp()
    clamp.input = simplex
    clamp.min = 0.3
    clamp.max = 0.8

This will clamp the noise values to 0.3 and 0.8.
There are also modules that accept two or three inputs. These are called `AHNCombiners` and `AHNSelectors` respectively. All `AHNGenerator`, `AHNModifier`, `AHNCombiner` and `AHNSelector` classes conform to the `AHNTextureProvider` protocol, which is the type used to provide input to a module. It is also the type that provides the `uiImage()` function to convert the underlying noise texture into a usable `UIImage`. A `UIImage` can then be converted into an `SKTexture` if necessary for use in gaming.


All classes have been marked up.

The example included shows how to generate a wood texture in only a few lines of code.


### Documentation
Full documentation is included as a pdf.
