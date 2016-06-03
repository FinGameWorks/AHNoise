# AHNoise
## A procedural, cohesive, modular noise library built using Metal and Swift

***

### Overview
Most of the classes in `AHNoise` will output a texture that can either be used as the input to another class, or converted into a `UIImage` for use. The only class that does not output a texture is `AHNContext`, which is a wrapper for the `Metal` classes used to communicate with the GPU. All other classes will output a texture by calling the `texture()` function. Most of the other classes will also allow an input texture to modify in some way. It is only `AHNGenerator` subclasses as well as the `AHNContext` class that have no input. `AHNModifier`s have one texture input and one texture output, `AHNCombiner`s have two texture inputs and one texture output and `AHNSelector`s have three texture inputs and one texture output. Each subclass has various tools and properties to modify behaviour too.


### Navigation
All classes in this module are prefixed with `AHN`. This is then split into categories such as `AHNGenerator`, `AHNModifier`, `AHNCombiner` and `AHNSelector`. These are superclasses designed to be subclassed into usable modules such as `AHNGeneratorSimplex` or `AHNCombinerMultiply` etc. The idea being that by starting to type `AHN` you are a presented with a list of all classes which can then be narrowed down as you continue to type.


### Usage
The first thing that needs to be created is an `AHNContext`.

`let context = AHNContext()`

You can define a specific `MTLDevice` to use in the initialiser, but it is not necessary. You should only need to create one `AHNContext`.

You can then use the `context` to create an `AHNGenerator` subclass. These classes have no input but output a texture, such as simplex noise. All module chains will start with one of these subclasses.

`let simplex = AHNGeneratorSimplex(context: context, textureWidth: 1024, textureHeight: 1024, use4DNoise: false, mapForSphere: false, makeSeamless: false)`

- The `textureWidth` and `textureHeight` parameters are the width and height of the output texture in pixels.
- The `use4DNoise` parameter dictates which version of simplex noise to use. 4D is more complex and computationally expensive but provides an extra degree of freedom with which to edit noise.
- The `mapForSphere` parameter maps the noise in such a way that it can be seamlessly wrapped onto a sphere with no warping.
- The `makeSeamless` parameter allows the output texture to be tiled seamlessly together, with no evident borders.

The generators also have properties such as `octaves`, `frequency`, `lacunarity` and `persistence` which all modify the output in various ways that are mentioned in the class markup. Most important of the four is `octaves` which compounds several layers of noise together. The default of `8` is a good start but higher values provide more detailed noise at a computational cost. The `frequency` parameters the next most important as it provides denser noise for higher values. The other two effect the interaction of the `frequency` for each of the compounded layers at each octave.

There are also parameters to move the texture around in "noise space" to provide variable output. You can animate noise by continuously varying the `zValue`, or make the texture appear to "crawl" by altering the `position` property. This obviously incurs a computational cost.

With the fist noise module ready it can either be directly turned into a `UIImage`:

`let image = simplex.uiImage()`

Otherwise it can be used as the input to another `AHNoise` module. For example it can have it's values clamped:

`let clamp = AHNModifierClamp(input: simplex, min: 0.3, max: 0.8)`

This will clamp the RGB values to 0.3 and 0.8.

All classes have been marked up with them to explain how they work.

The example included shows how to generate a wood texture in only a few lines of code.

### A Note on Noise and Colour Space
Perhaps the most confusing thing in the markup is the comparison of "Noise Space" and "Colour Space". The difference is that the simplex algorithm outputs values in the range -1.0 to 1.0, whereas RGB values need to be in the range 0.0 to 1.0. The two are mapped together linearly using the formula `colour = (noise/2)+0.5`. In the markup the colour values appear in square brackets `[0.5]`, and each module dictates which space it works in where needed. Most of the time you won't need to know the difference but it helps to understand where differences arise. Both values are retained as some classes such as `AHNModifierAbsolute` would have no effect on a range of 0.0 to 1.0, whereas others such as `AHNCombinerMultiply` would result in negative values if noises space were used.


### Documentation
Full documentation is on the way. But for now the markup is enough to get started.
