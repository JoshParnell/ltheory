/* --- Far-Plane Projection ----------------------------------------------------
    Pushes vertices all the way to the camera's far plane, such that they are
    guaranteed to be 'in the background,' except when multiple objects are
    projecting to the far plane (in which case, they should be drawn
    back-to-front).

    Primarily used for skyboxes, stars, etc -- objects that should appear to
    be infinitely far away. No local->world transform is applied.

    Requires:
      * An active camera
----------------------------------------------------------------------------- */

#include vertex

#autovar mat4 mView
#autovar mat4 mProj

void main() {
  VS_BEGIN
  normal = vertNormal;
  vec4 v = vec4(farPlane * vertPos, 0.0);
  pos = v.xyz;
  v = mView * v;
  gl_Position = mProj * v;
  gl_Position.z = gl_Position.w;
  // VS_END
}
