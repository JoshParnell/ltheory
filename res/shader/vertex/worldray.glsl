#include vertex

#autovar mat4 mView
#autovar mat4 mProj
#autovar mat4 mViewInv
#autovar mat4 mProjInv

varying vec3 worldOrigin;
varying vec3 worldDir;

void main () {
  vec4 p1 = mViewInv * vec4(0.0, 0.0, 0.0, 1.0);
  vec4 p2 = mProjInv * vec4(gl_Vertex.xy, 1.0, 1.0);
  p2 /= p2.w;
  p2 = mViewInv * p2;

  worldOrigin = p1.xyz;
  worldDir = p2.xyz - p1.xyz;

  gl_Position = vec4(gl_Vertex.xyz, 1.0);
  uv = gl_MultiTexCoord0.xy;
}
