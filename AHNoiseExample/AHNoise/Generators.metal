//
//  Simplex.metal
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;

// MARK: - Raw simplex functions

static constant float3 grad3 [12] = {float3(1,1,0),float3(-1,1,0),float3(1,-1,0),float3(-1,-1, 0),float3(1,0,1),float3(-1,0,1),float3(1,0,-1),float3(-1,0,-1),float3(0,1,1),float3(0,-1,1),float3(0,1,-1),float3(0,-1,-1)};

static constant float4 grad4 [32] = {float4(0,1,1,1),float4(0,1,1,-1),float4(0,1,-1,1),float4(0,1,-1,-1),float4(0,-1,1,1),float4(0,-1,1,-1),float4(0,-1,-1,1),float4(0,-1,-1,-1),float4(1,0,1,1),float4(1,0,1,-1),float4(1,0,-1,1),float4(1,0,-1,-1),float4(-1,0,1,1),float4(-1,0,1,-1),float4(-1,0,-1,1),float4(-1,0,-1,-1),float4(1,1,0,1),float4(1,1,0,-1),float4(1,-1,0,1),float4(1,-1,0,-1),float4(-1,1,0,1),float4(-1,1,0,-1),float4(-1,-1,0,1),float4(-1,-1,0,-1),float4(1,1,1,0),float4(1,1,-1,0),float4(1,-1,1,0),float4(1,-1,-1,0),float4(-1,1,1,0),float4(-1,1,-1,0),float4(-1,-1,1,0),float4(-1,-1,-1,0)};

static constant int perm [512] = {151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180};

static constant int permMod12 [512] = {7,4,5,7,6,3,11,1,9,11,0,5,2,5,7,9,8,0,7,6,9,10,8,3,1,0,9,10,11,10,6,4,7,0,6,3,0,2,5,2,10,0,3,11,9,11,11,8,9,9,9,4,9,5,8,3,6,8,5,4,3,0,8,7,2,9,11,2,7,0,3,10,5,2,2,3,11,3,1,2,0,7,1,2,4,9,8,5,7,10,5,4,4,6,11,6,5,1,3,5,1,0,8,1,5,4,0,7,4,5,6,1,8,4,3,10,8,8,3,2,8,4,1,6,5,6,3,4,4,1,10,10,4,3,5,10,2,3,10,6,3,10,1,8,3,2,11,11,11,4,10,5,2,9,4,6,7,3,2,9,11,8,8,2,8,10,7,10,5,9,5,11,11,7,4,9,9,10,3,1,7,2,0,2,7,5,8,4,10,5,4,8,2,6,1,0,11,10,2,1,10,6,0,0,11,11,6,1,9,3,1,7,9,2,11,11,1,0,10,7,1,7,10,1,4,0,0,8,7,1,2,9,7,4,6,2,6,8,1,9,6,6,7,5,0,0,3,9,8,3,6,6,11,1,0,0,7,4,5,7,6,3,11,1,9,11,0,5,2,5,7,9,8,0,7,6,9,10,8,3,1,0,9,10,11,10,6,4,7,0,6,3,0,2,5,2,10,0,3,11,9,11,11,8,9,9,9,4,9,5,8,3,6,8,5,4,3,0,8,7,2,9,11,2,7,0,3,10,5,2,2,3,11,3,1,2,0,7,1,2,4,9,8,5,7,10,5,4,4,6,11,6,5,1,3,5,1,0,8,1,5,4,0,7,4,5,6,1,8,4,3,10,8,8,3,2,8,4,1,6,5,6,3,4,4,1,10,10,4,3,5,10,2,3,10,6,3,10,1,8,3,2,11,11,11,4,10,5,2,9,4,6,7,3,2,9,11,8,8,2,8,10,7,10,5,9,5,11,11,7,4,9,9,10,3,1,7,2,0,2,7,5,8,4,10,5,4,8,2,6,1,0,11,10,2,1,10,6,0,0,11,11,6,1,9,3,1,7,9,2,11,11,1,0,10,7,1,7,10,1,4,0,0,8,7,1,2,9,7,4,6,2,6,8,1,9,6,6,7,5,0,0,3,9,8,3,6,6,11,1,0,0};

// Skewing and unskewing factors for 3/4D
static constant float F3 = 1.0/3.0;
static constant float G3 = 1.0/6.0;
static constant float F4 = 0.3090169944;
static constant float G4 = 0.1381966011;

// 3D Simplex Noise
float simplex3D(float xin, float yin, float zin);
float simplex3D(float xin, float yin, float zin)
{
  float3 pos = float3(xin,yin,zin);
  float s = (pos.x+pos.y+pos.z)*F3;
  
  // Noise contribution from the four corners
  float n0; float n1; float n2; float n3;
  
  // Skew the input space to determine which simplex cell we're in
  int i = floor(pos.x+s);
  int j = floor(pos.y+s);
  int k = floor(pos.z+s);
  float t = (i+j+k)*G3;
  
  // Unskew the cell origin back to x,y,z space
  float X0 = i-t;
  float Y0 = j-t;
  float Z0 = k-t;
  
  // The x,y,z distance from the cell origin
  float x0 = pos.x - X0;
  float y0 = pos.y - Y0;
  float z0 = pos.z - Z0;
  
  // For the 3D case the simplex shape is a slightly irregular tetrahedron.
  // Determine which simplex we are in.
  int i1 = 0; int j1 = 0; int k1 = 0;
  int i2 = 0; int j2 = 0; int k2 = 0;
  
  if (x0>=y0){
    if (y0>=z0){
      i1 = 1; i2 = 1; j2 = 1;		// X Y Z order
    }else if (x0>=z0){
      i1=1; i2=1; k2=1;		// X Z Y order
    }else{
      k1=1; i2=1; k2=1;		// Z X Y order
    }
  }else{	// x0<y0
    if (y0<z0){
      k1=1; j2=1; k2=1;		// Z Y X order
    }else if (x0<z0){
      j1=1; j2=1; k2=1;		// Y Z X order
    }else{
      j1=1; i2=1; j2=1;		// Y X Z order
    }
  }
  
  // A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
  // a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
  // a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
  // c = 1/6.
  
  // Offsets for second corner in (x,y,z) coords
  float x1 = x0 - i1 + G3;
  float y1 = y0 - j1 + G3;
  float z1 = z0 - k1 + G3;
  
  // Offsets for third corner in (x,y,z) coords
  float x2 = x0 - i2 + 2.0*G3;
  float y2 = y0 - j2 + 2.0*G3;
  float z2 = z0 - k2 + 2.0*G3;
  
  // Offsets for last corner in (x,y,z) coords
  float x3 = x0 - 1.0 + 3.0*G3;
  float y3 = y0 - 1.0 + 3.0*G3;
  float z3 = z0 - 1.0 + 3.0*G3;
  
  // Work out the hashed gradient indices of the four simplex corners
  int ii = i & 255;
  int jj = j & 255;
  int kk = k & 255;
  int gi0 = permMod12[ii+perm[jj+perm[kk]]];
  int gi1 = permMod12[ii+i1+perm[jj+j1+perm[kk+k1]]];
  int gi2 = permMod12[ii+i2+perm[jj+j2+perm[kk+k2]]];
  int gi3 = permMod12[ii+1+perm[jj+1+perm[kk+1]]];
  
  // Calculate the contribution from the four corners
  float t0 = 0.6 - x0*x0 - y0*y0 - z0*z0;
  if (t0<0){
    n0 = 0.0;
  }else{
    t0 *= t0;
    n0 = t0 * t0 * dot(grad3[gi0],float3(x0, y0, z0));
  }
  float t1 = 0.6 - x1*x1 - y1*y1 - z1*z1;
  if (t1<0){
    n1 = 0.0;
  }else{
    t1 *= t1;
    n1 = t1 * t1 * dot(grad3[gi1],float3(x1, y1, z1));
  }
  float t2 = 0.6 - x2*x2 - y2*y2 - z2*z2;
  if (t2<0){
    n2 = 0.0;
  }else{
    t2 *= t2;
    n2 = t2 * t2 * dot(grad3[gi2],float3(x2, y2, z2));
  }
  float t3 = 0.6 - x3*x3 - y3*y3 - z3*z3;
  if (t3<0){
    n3 = 0.0;
  }else{
    t3 *= t3;
    n3 = t3 * t3 * dot(grad3[gi3],float3(x3, y3, z3));
  }
  
  // Add contributions from each corner to get the final noise value.
  // The result is scaled to stay just inside the range -1,1
  return 32.0*(n0 + n1 + n2 + n3);
}

// 4D Simplex Noise
float simplex4D(float xin, float yin, float zin, float win);
float simplex4D(float xin, float yin, float zin, float win)
{
  float4 pos = float4(xin,yin,zin,win);
  
  // Noise contribution from the four corners
  float n0; float n1; float n2; float n3; float n4;
  
  // Factor for 4D skewing
  float s = (pos.x+pos.y+pos.z+pos.w)*F4;
  
  // Skew the (x,y,z,w) space to determine which cell of 24 simplices we are in
  int i = floor(pos.x+s);
  int j = floor(pos.y+s);
  int k = floor(pos.z+s);
  int l = floor(pos.w+s);
  float t = (i+j+k+l)*G4;
  
  // Unskew the cell origin back to x,y,z,w space
  float X0 = i-t;
  float Y0 = j-t;
  float Z0 = k-t;
  float W0 = l-t;
  
  // The x,y,z,w distance from the cell origin
  float x0 = pos.x - X0;
  float y0 = pos.y - Y0;
  float z0 = pos.z - Z0;
  float w0 = pos.w - W0;
  
  // For the 4D case, the simplex is a 4D shape I won't even try to describe.
  // To find out which of the 24 possible simplices we're in, we need to
  // determine the magnitude ordering of x0, y0, z0 and w0.
  // Six pair-wise comparisons are performed between each possible pair
  // of the four coordinates, and the results are used to rank the numbers.
  int rankx = 0;
  int ranky = 0;
  int rankz = 0;
  int rankw = 0;
  
  if (x0>y0){rankx++;}else{ranky++;}
  if (x0>z0){rankx++;}else{rankz++;}
  if (x0>w0){rankx++;}else{rankw++;}
  if (y0>z0){ranky++;}else{rankz++;}
  if (y0>w0){ranky++;}else{rankw++;}
  if (z0>w0){rankz++;}else{rankw++;}
  
  // The integer offsets for the second simplex corner
  int i1 = 0; int j1 = 0; int k1 = 0; int l1 = 0;
  // The integer offsets for the third simplex corner
  int i2 = 0; int j2 = 0; int k2 = 0; int l2 = 0;
  // The integer offsets for the fourth simplex corner
  int i3 = 0; int j3 = 0; int k3 = 0; int l3 = 0;
  
  // simplex[c] is a 4-vector with the numbers 0, 1, 2 and 3 in some order.
  // Many values of c will never occur, since e.g. x>y>z>w makes x<z, y<w and x<w
  // impossible. Only the 24 indices which have non-zero entries make any sense.
  // We use a threshold to set the coordinates in turn from the largest magnitude.
  
  // Rank 3 denotes the largest coordinate.
  i1 = rankx >= 3 ? 1 : 0;
  j1 = ranky >= 3 ? 1 : 0;
  k1 = rankz >= 3 ? 1 : 0;
  l1 = rankw >= 3 ? 1 : 0;
  
  // Rank 2 deonted the second largest coordinate.
  i2 = rankx >= 2 ? 1 : 0;
  j2 = ranky >= 2 ? 1 : 0;
  k2 = rankz >= 2 ? 1 : 0;
  l2 = rankw >= 2 ? 1 : 0;
  
  // Rank 1 deonted the second smallest coordinate.
  i3 = rankx >= 1 ? 1 : 0;
  j3 = ranky >= 1 ? 1 : 0;
  k3 = rankz >= 1 ? 1 : 0;
  l3 = rankw >= 1 ? 1 : 0;
  
  // The fifth corner has all coordinate offsets = -1, so no need to compute it.
  
  
  // Offsets for second corner in (x,y,z,w) coords
  float x1 = x0 - i1 + G4;
  float y1 = y0 - j1 + G4;
  float z1 = z0 - k1 + G4;
  float w1 = w0 - l1 + G4;
  
  // Offsets for third corner in (x,y,z,w) coords
  float x2 = x0 - i2 + 2.0*G4;
  float y2 = y0 - j2 + 2.0*G4;
  float z2 = z0 - k2 + 2.0*G4;
  float w2 = w0 - l2 + 2.0*G4;
  
  // Offsets for fourth corner in (x,y,z,w) coords
  float x3 = x0 - i3 + 3.0*G4;
  float y3 = y0 - j3 + 3.0*G4;
  float z3 = z0 - k3 + 3.0*G4;
  float w3 = w0 - l3 + 3.0*G4;
  
  // Offsets for lastcorner in (x,y,z,w) coords
  float x4 = x0 - 1.0 + 4.0*G4;
  float y4 = y0 - 1.0 + 4.0*G4;
  float z4 = z0 - 1.0 + 4.0*G4;
  float w4 = w0 - 1.0 + 4.0*G4;
  
  // Work out the hashed gradient indices of the five simplex corners
  int ii = i & 255;
  int jj = j & 255;
  int kk = k & 255;
  int ll = l & 255;
  int gi0 = perm[ii+perm[jj+perm[kk+perm[ll]]]] % 32;
  int gi1 = perm[ii+i1+perm[jj+j1+perm[kk+k1+perm[ll+l1]]]] % 32;
  int gi2 = perm[ii+i2+perm[jj+j2+perm[kk+k2+perm[ll+l2]]]] % 32;
  int gi3 = perm[ii+i3+perm[jj+j3+perm[kk+k3+perm[ll+l3]]]] % 32;
  int gi4 = perm[ii+1+perm[jj+1+perm[kk+1+perm[ll+1]]]] % 32;
  
  // Calculate the contribution from the five corners
  float t0 = 0.6 - x0*x0 - y0*y0 - z0*z0 - w0*w0;
  if (t0<0){
    n0 = 0.0;
  }else{
    t0 *= t0;
    n0 = t0 * t0 * dot(grad4[gi0],float4(x0, y0, z0, w0));
  }
  float t1 = 0.6 - x1*x1 - y1*y1 - z1*z1 - w1*w1;
  if (t1<0){
    n1 = 0.0;
  }else{
    t1 *= t1;
    n1 = t1 * t1 * dot(grad4[gi1],float4(x1, y1, z1, w1));
  }
  float t2 = 0.6 - x2*x2 - y2*y2 - z2*z2 - w2*w2;
  if (t2<0){
    n2 = 0.0;
  }else{
    t2 *= t2;
    n2 = t2 * t2 * dot(grad4[gi2],float4(x2, y2, z2, w2));
  }
  float t3 = 0.6 - x3*x3 - y3*y3 - z3*z3 - w3*w3;
  if (t3<0){
    n3 = 0.0;
  }else{
    t3 *= t3;
    n3 = t3 * t3 * dot(grad4[gi3],float4(x3, y3, z3, w3));
  }
  float t4 = 0.6 - x4*x4 - y4*y4 - z4*z4 - w4*w4;
  if (t4<0){
    n4 = 0.0;
  }else{
    t4 *= t4;
    n4 = t4 * t4 * dot(grad4[gi4],float4(x4, y4, z4, w4));
  }
  
  // Add contributions from each corner to get the final noise value.
  // The result is scaled to stay just inside the range -1,1
  return 27.0 * (n0 + n1 + n2 + n3 + n4);
}


























// MARK: - Simplex Kernels

struct SimplexInputs{
  float2 pos;
  int octaves;
  float persistance;
  float frequency;
  float lacunarity;
  float z;
  float w;
  int useFourD;
  int sphereMap;
  int seamless;
};

kernel void simplexGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             constant SimplexInputs &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]],
                             uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;
  
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistance = uniforms.persistance;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x));
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y));
  float z = uniforms.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*y)*sin(pi*x);
    float yy = sin(pi*2*y)*sin(pi*x);
    z = cos(pi*x);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
  }
  
  for (int j = 0; j < octaves; ++j){
    if (use4D == 0){
      total += ((simplex3D(x*freq,y*freq,z*freq)+1)/2) * amplitude;
    }else{
      total += ((simplex4D(x*freq,y*freq,z*freq,w*freq)+1)/2) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistance;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}

// MARK: - Billow Kernel
kernel void billowGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                            constant SimplexInputs &uniforms [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]],
                            uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;
  
  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistance = uniforms.persistance;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x));
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y));
  float z = uniforms.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*y)*sin(pi*x);
    float yy = sin(pi*2*y)*sin(pi*x);
    z = cos(pi*x);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
  }
  
  for (int j = 0; j < octaves; ++j){
    
    if (use4D == 0){
      total += abs(simplex3D(x*freq,y*freq,z*freq)) * amplitude;
    }else{
      total += abs(simplex4D(x*freq,y*freq,z*freq,w*freq)) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistance;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}

// MARK: - Ridged Multi Kernel
kernel void ridgedMultiGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                                 constant SimplexInputs &uniforms [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]],
                                 uint2 threads [[threads_per_grid]])
{
  float total = 0.0;
  float amplitude = 1.0;
  float maxAmplitude = 0.0;
  int use4D = uniforms.useFourD;
  int sphereMap = uniforms.sphereMap;
  int seamless = uniforms.seamless;

  int octaves = uniforms.octaves;
  float freq = uniforms.frequency;
  float lacunarity = uniforms.lacunarity;
  float persistance = uniforms.persistance;
  float x = uniforms.pos.x + (float(gid.x)/float(threads.x));
  float y = uniforms.pos.y + (float(gid.y)/float(threads.y));
  float z = uniforms.z;
  float w = uniforms.w;
  
  if (sphereMap != 0){
    float pi = 3.14159265;
    float xx = cos(pi*2*y)*sin(pi*x);
    float yy = sin(pi*2*y)*sin(pi*x);
    z = cos(pi*x);
    x = xx;
    y = yy;
  }
  
  if (seamless != 0){
    float pi = 3.14159265;
    
    float nx = cos(2*pi*x);
    float ny = cos(2*pi*y);
    float nz = sin(2*pi*x);
    float nw = sin(2*pi*y);
    x = nx;
    y = ny;
    z = nz;
    w = nw;
  }
  
  for (int j = 0; j < octaves; ++j){
    if (use4D == 0){
      total += (-abs(simplex3D(x*freq,y*freq,z*freq))+1) * amplitude;
    }else{
      total += (-abs(simplex4D(x*freq,y*freq,z*freq,w*freq))+1) * amplitude;
    }
    
    freq *= lacunarity;
    maxAmplitude += amplitude;
    amplitude *= persistance;
  }
  
  float r = total / maxAmplitude;
  outTexture.write(float4(r,r,r,1),gid);
}

// MARK: - Uniform Output Kernel
kernel void uniformGenerator(texture2d<float, access::write> outTexture [[texture(0)]],
                             constant float3 &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
  outTexture.write(float4(uniforms,1),gid);
}


// MARK: - Test Kernel
kernel void test(constant SimplexInputs &uniforms [[buffer(0)]],
                 device float &outBuffer [[buffer(1)]],
                 uint2 gid [[threads_per_grid]],
                 uint2 gp [[thread_position_in_grid]])
{
  
    outBuffer = uniforms.sphereMap;
}

