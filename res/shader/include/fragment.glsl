#include common

varying vec2 uv;
varying vec3 pos;
varying vec3 normal;
varying vec3 vertNormal;
varying vec3 vertPos;
varying float flogz;

uniform vec3 eye;
uniform mat4 mWorldIT;

uniform samplerCube envMap;
uniform samplerCube irMap;
uniform vec3 starColor;
uniform vec3 starDir;

#define FRAGMENT_CORRECT_DEPTH                                                 \
  gl_FragDepth = log2(flogz) * (0.5 * Fcoef);
