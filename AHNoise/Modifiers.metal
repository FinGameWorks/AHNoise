//
//  Modifiers.metal
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Absolute Modifier
kernel void absoluteModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                             texture2d<float, access::write> outTexture [[texture(1)]],
                             constant bool &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
  float4 in = (inTexture.read(gid)*2)-1;
  float3 out = abs(in.rgb);
  if (uniforms == false){
    out = (out+1)/2;
  }
  outTexture.write(float4(out,1), gid);
}

// Clamp Modifier
struct ClampModifierUniforms {
  bool normalise;
  float2 clampValues;
};

kernel void clampModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                          texture2d<float, access::write> outTexture [[texture(1)]],
                          constant ClampModifierUniforms &uniforms [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  bool normalise = uniforms.normalise;
  float mi = uniforms.clampValues.x;
  float ma = uniforms.clampValues.y;
  
  float3 out = clamp(in.rgb, mi, ma);
  float o = (out.r+out.g+out.b)/3;
  
  if (normalise == true){
    float average = (mi+ma)/2;
    float movedMin = mi-average;
    float movedMax = ma-average;
    in.rgb -= average;
    if (o<0){
      in.rgb /= abs(movedMin);
    }else{
      in.rgb /= movedMax;
    }
    in.rgb /= 2;
    in.rgb += 0.5;
    
  }
  outTexture.write(float4(in.rgb,1), gid);
}


// Step Modifier
kernel void stepModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant float3 &uniforms [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  float out = (in.r+in.g+in.b)/3;
  if (out < uniforms.z){
    out = uniforms.x;
  }else{
    out = uniforms.y;
  }
  outTexture.write(float4(out,out,out,1), gid);
}

// Invert Modifier
kernel void invertModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                           texture2d<float, access::write> outTexture [[texture(1)]],
                           uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  float3 out = 1 - in.rgb;
  outTexture.write(float4(out,1), gid);
}

// Scale Bias Modifier
kernel void scaleBiasModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant float2 &uniforms [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  float3 out = (in.rgb * uniforms.x)+uniforms.y;
  outTexture.write(float4(out,1), gid);
}

// Round Modifier
kernel void roundModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                          texture2d<float, access::write> outTexture [[texture(1)]],
                          constant float &uniforms [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  float3 out = in.rgb;
  float n = uniforms;
  out /= n;
  out = round(out);
  out *= n;
  outTexture.write(float4(out,1), gid);
}

// Loop Modifier
struct LoopModifierUniforms {
  bool normalise;
  float loopValue;
};

kernel void loopModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant LoopModifierUniforms &uniforms [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  bool normalise = uniforms.normalise;
  float loop = uniforms.loopValue;
  float out = ((in.r+in.g+in.b)/3) / loop;
  float fout = floor(out);
  out = out - fout;
  if (normalise == false){
    out *= loop;
  }
  outTexture.write(float4(out,out,out,1), gid);
}

// Stretch Modifier
kernel void stretchModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant float4 &uniforms [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]],
                            uint2 threads [[threads_per_grid]])
{
  float xScale = uniforms.x;
  float yScale = uniforms.y;
  float xAnchor = uniforms.z;
  float yAnchor = uniforms.w;
  float inX = float(gid.x);
  float inY = float(gid.y);
  uint2 halfSize = uint2(threads.x * xAnchor, threads.y * yAnchor);
  float scaledX = halfSize.x + ((inX - halfSize.x) / xScale);
  float scaledY = halfSize.y + ((inY - halfSize.y) / yScale);
  
  float4 out = float4(0,0,0,0);
  bool interpolate = true;
  if (scaledX < 0 || scaledX > threads.x || scaledY < 0 || scaledY > threads.y){
    interpolate = false;
  }
  
  if (interpolate){
    int scaledXF = floor(scaledX);
    int scaledXC = ceil(scaledX);
    float facX = fract(scaledX);
    int scaledYF = floor(scaledY);
    int scaledYC = ceil(scaledY);
    float facY = fract(scaledY);
    
    
    float4 in1 = inTexture.read(uint2(scaledXF, scaledYF));
    float4 in2 = inTexture.read(uint2(scaledXF, scaledYC));
    float4 in3 = inTexture.read(uint2(scaledXC, scaledYF));
    float4 in4 = inTexture.read(uint2(scaledXC, scaledYC));
    
    float4 out1 = mix(in1, in3, facX);
    float4 out2 = mix(in2, in4, facX);
    out = mix(out1, out2, facY);
  }
  outTexture.write(out, gid);
}

// Normal Map Modifier
struct NormalMapModifierUniforms {
  float intensity;
  int2 axes;
};

kernel void normalMapModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              constant NormalMapModifierUniforms &uniforms [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]],
                              uint2 threads [[threads_per_grid]])
{
  uint x1 = gid.x == 0 ? gid.x : gid.x - 1;
  uint y1 = gid.y == 0 ? gid.y : gid.y - 1;
  uint x2 = gid.x == threads.x ? gid.x : gid.x + 1;
  uint y2 = gid.y == threads.y ? gid.y : gid.y + 1;
  
  uint xRange = 2.0;
  uint yRange = 2.0;
  
  if (gid.x == 0 || gid.x == threads.x){
    xRange = 1;
  }
  if (gid.y == 0 || gid.y == threads.y){
    yRange = 1;
  }
  
  
  float4 lowX4 = inTexture.read(uint2(x1, gid.y));
  float4 highX4 = inTexture.read(uint2(x2, gid.y));
  float4 lowY4 = inTexture.read(uint2(gid.x, y1));
  float4 highY4 = inTexture.read(uint2(gid.x, y2));
  
  float intensity = uniforms.intensity;

  float lowX = ((lowX4.r + lowX4.g + lowX4.b)/3) * intensity;
  float highX = ((highX4.r + highX4.g + highX4.b)/3) * intensity;
  float lowY = ((lowY4.r + lowY4.g + lowY4.b)/3) * intensity;
  float highY = ((highY4.r + highY4.g + highY4.b)/3) * intensity;
  
  float dx = ((highX - lowX)/xRange);
  float dy = ((highY - lowY)/yRange);
  
  int2 axisFlip = uniforms.axes;
  
  if (axisFlip.x != 0){
    dx *= -1;
  }
  if (axisFlip.y != 0){
    dy *= -1;
  }
  
  
  float3 out = float3(dx+0.5, dy+0.5, 1);
  out = normalize(out);

  outTexture.write(float4(out,1), gid);
}







// Colour Modifier
struct ColourProperties{
  float4 colour;
  float4 props;
};

kernel void colourModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant ColourProperties &uniforms [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
  float4 in = inTexture.read(gid);
  float out = (in.r+in.g+in.b)/3;

  float3 c = uniforms.colour.rgb;
  float p = uniforms.props.x;
  float lr = uniforms.props.y;
  float ur = uniforms.props.z;
  float l = p - lr;
  float u = p + ur;

  float3 o = in.rgb;
  if (out >= l && out <= p){
    float fac = (out - l) / lr;
    o = mix(in.rgb, c, fac);
  }
  if (out > p && out <= u){
    float fac = (u - out) / ur;
    o = mix(in.rgb, c, fac);
  }
  
  outTexture.write(float4(o,1), gid);
}

// Rotate Modifier
kernel void rotateModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant float4 &uniforms [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]],
                            uint2 threads [[threads_per_grid]])
{
  float xAnchor = uniforms.x;
  float yAnchor = uniforms.y;
  float angle = uniforms.z;
  float2 o = float2(threads.x * xAnchor, threads.y * yAnchor);
  
  float rotatedX = ( (gid.x-o.x) * cos(angle) )  -  ( (gid.y-o.y) * sin(angle) )  +  o.x;
  float rotatedY = ( (gid.y-o.y) * cos(angle) )  +  ( (gid.x-o.x) * sin(angle) )  +  o.y;
  
  float4 out = float4(0,0,0,0);
  bool interpolate = true;
  if (uniforms.w == 1){
    if (rotatedX < 0 || rotatedX > threads.x || rotatedY < 0 || rotatedY > threads.y){
      interpolate = false;
    }
  }
  
  if (interpolate){
    int rotatedXF = floor(rotatedX);
    int rotatedXC = ceil(rotatedX);
    float facX = fract(rotatedX);
    int rotatedYF = floor(rotatedY);
    int rotatedYC = ceil(rotatedY);
    float facY = fract(rotatedY);
    
    
    float4 in1 = inTexture.read(uint2(rotatedXF, rotatedYF));
    float4 in2 = inTexture.read(uint2(rotatedXF, rotatedYC));
    float4 in3 = inTexture.read(uint2(rotatedXC, rotatedYF));
    float4 in4 = inTexture.read(uint2(rotatedXC, rotatedYC));
    
    float4 out1 = mix(in1, in3, facX);
    float4 out2 = mix(in2, in4, facX);
    out = mix(out1, out2, facY);
  }
  outTexture.write(out, gid);
}

// Swirl Modifier
kernel void swirlModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                           texture2d<float, access::write> outTexture [[texture(1)]],
                           constant float4 &uniforms [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]],
                           uint2 threads [[threads_per_grid]])
{
  float xAnchor = uniforms.x;
  float yAnchor = uniforms.y;
  float2 o = float2(threads.x * xAnchor, threads.y * yAnchor);

  float dx = abs(gid.x - o.x) / threads.x;
  float dy = abs(gid.y - o.y) / threads.y;
  float i = sqrt(2.0)-sqrt(dx*dx + dy*dy);
  float angle = uniforms.z * i;
  
  float rotatedX = ( (gid.x-o.x) * cos(angle) )  -  ( (gid.y-o.y) * sin(angle) )  +  o.x;
  float rotatedY = ( (gid.y-o.y) * cos(angle) )  +  ( (gid.x-o.x) * sin(angle) )  +  o.y;
  
  float4 out = float4(0,0,0,0);
  bool interpolate = true;
  if (uniforms.w == 1){
    if (rotatedX < 0 || rotatedX > threads.x || rotatedY < 0 || rotatedY > threads.y){
      interpolate = false;
    }
  }
  if (interpolate){
    int rotatedXF = floor(rotatedX);
    int rotatedXC = ceil(rotatedX);
    float facX = fract(rotatedX);
    int rotatedYF = floor(rotatedY);
    int rotatedYC = ceil(rotatedY);
    float facY = fract(rotatedY);
    
    
    float4 in1 = inTexture.read(uint2(rotatedXF, rotatedYF));
    float4 in2 = inTexture.read(uint2(rotatedXF, rotatedYC));
    float4 in3 = inTexture.read(uint2(rotatedXC, rotatedYF));
    float4 in4 = inTexture.read(uint2(rotatedXC, rotatedYC));
    
    float4 out1 = mix(in1, in3, facX);
    float4 out2 = mix(in2, in4, facX);
    out = mix(out1, out2, facY);
  }
  outTexture.write(out, gid);
}

// Perspective Modifier
kernel void perspectiveModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                          texture2d<float, access::write> outTexture [[texture(1)]],
                          constant float3 &uniforms [[buffer(0)]],
                          uint2 gid [[thread_position_in_grid]],
                          uint2 threads [[threads_per_grid]])
{
  float xScale = uniforms.x;
  float yScale = uniforms.y;
  float direction = uniforms.z;

  float inX = float(gid.x);
  float inY = float(gid.y);
  uint2 halfSize = uint2(threads.x/2, 0);
  float scaledX = halfSize.x + ((inX - halfSize.x - (halfSize.x * direction * (inY/threads.y))) / (1 - (xScale * (inY/threads.y))));
  float scaledY = halfSize.y + ((inY - halfSize.y) / yScale);
  
  
  float4 out = float4(0,0,0,0);
  bool interpolate = true;
  if (scaledX < 0 || scaledX > threads.x || scaledY < 0 || scaledY > threads.y){
    interpolate = false;
  }
  
  if (interpolate){
    int scaledXF = floor(scaledX);
    int scaledXC = ceil(scaledX);
    float facX = fract(scaledX);
    int scaledYF = floor(scaledY);
    int scaledYC = ceil(scaledY);
    float facY = fract(scaledY);
    
    
    float4 in1 = inTexture.read(uint2(scaledXF, scaledYF));
    float4 in2 = inTexture.read(uint2(scaledXF, scaledYC));
    float4 in3 = inTexture.read(uint2(scaledXC, scaledYF));
    float4 in4 = inTexture.read(uint2(scaledXC, scaledYC));
    
    float4 out1 = mix(in1, in3, facX);
    float4 out2 = mix(in2, in4, facX);
    out = mix(out1, out2, facY);
  }
  outTexture.write(out, gid);
}

struct ScaleCanvasProperties{
  float4 scale;
  uint4 oldSize;
};

// ScaleCanvas Modifier
kernel void scaleCanvasModifier(texture2d<float, access::read> inTexture [[texture(0)]],
                                texture2d<float, access::write> outTexture [[texture(1)]],
                                constant ScaleCanvasProperties &uniforms [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]],
                                uint2 threads [[threads_per_grid]])
{
  float xAnchor = uniforms.scale.x * threads.x;
  float yAnchor = uniforms.scale.y * threads.y;
  float xScale = uniforms.scale.z;
  float yScale = uniforms.scale.w;
  int inputWidth = uniforms.oldSize.x;
  int inputHeight = uniforms.oldSize.y;
  
  float inX = float(gid.x);
  float inY = float(gid.y);
  float scaledX = (inX-xAnchor)/xScale;
  float scaledY = (inY-yAnchor)/yScale;
  
  
  float4 out = float4(0,0,0,0);
  bool interpolate = true;
  if (scaledX < 0 || scaledX > inputWidth || scaledY < 0 || scaledY > inputHeight){
    interpolate = false;
  }
  
  if (interpolate){
    int scaledXF = floor(scaledX);
    int scaledXC = ceil(scaledX);
    float facX = fract(scaledX);
    int scaledYF = floor(scaledY);
    int scaledYC = ceil(scaledY);
    float facY = fract(scaledY);
    
    
    float4 in1 = inTexture.read(uint2(scaledXF, scaledYF));
    float4 in2 = inTexture.read(uint2(scaledXF, scaledYC));
    float4 in3 = inTexture.read(uint2(scaledXC, scaledYF));
    float4 in4 = inTexture.read(uint2(scaledXC, scaledYC));
    
    float4 out1 = mix(in1, in3, facX);
    float4 out2 = mix(in2, in4, facX);
    out = mix(out1, out2, facY);
  }
  outTexture.write(out, gid);
}