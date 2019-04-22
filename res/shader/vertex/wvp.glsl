/* -- World-View-Projection ----------------------------------------------------
   The standard projection pipeline for game objects in world-space.

   Requires:
     * An active camera to provide view & projection matrices
     * mWorld matrix providing object's local->world transform
     * mWorldIT matrix (inverse-transpose of mWorld)
----------------------------------------------------------------------------- */

#include vertex

#autovar mat4 mView
#autovar mat4 mProj

void main() {
  VS_BEGIN
  normal = normalize((mWorldIT * vec4(vertex_normal, 0)).xyz);
  vec4 v = vec4(vertex_position, 1.0);
  vec4 wp = mWorld * v;
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  VS_END
}
