/* -- View-Projection ----------------------------------------------------------
   Identical to World-View-Projection, except that the object's local->world
   transform is assumed to be identity (that is, no mWorld or mWorldIT matrices
   are required as they are assumed to be identity).

   Requires:
     * An active camera to provide view & projection matrices
----------------------------------------------------------------------------- */

#include vertex

#autovar mat4 mView
#autovar mat4 mProj

void main() {
  VS_BEGIN
  normal = normalize(vertex_normal);
  vec4 wp = vec4(vertex_position, 1.0);
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  VS_END
}
