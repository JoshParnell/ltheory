#include common

attribute vec3 vertex_position;
attribute vec3 vertex_normal;
attribute vec2 vertex_uv;
attribute vec3 vertex_color;

varying vec2 uv;
varying vec3 pos;
varying vec3 normal;
varying vec3 vertNormal;
varying vec3 vertPos;
varying float flogz;

uniform vec3 eye;
uniform mat4 mWorld;
uniform mat4 mWorldIT;
uniform mat4 mView;
uniform mat4 mViewInv;
uniform mat4 mProj;
uniform mat4 mProjInv;

#define VS_BEGIN                                                               \
  uv = vertex_uv;                                                              \
  vertPos = vertex_position;                                                   \
  vertNormal = vertex_normal;                                                  \

#define VS_END                                                                 \
  gl_Position = logDepth(gl_Position);

vec4 logDepth(vec4 p) {
  p.z = log2(max(1e-6, 1.0 + abs(p.w))) * Fcoef - 1.0;
  p.z *= p.w;
  flogz = 1.0 + p.w;
  return p;
}
