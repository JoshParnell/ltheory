#include vertex
#include math

#autovar vec3 eye
#autovar mat4 mView
#autovar mat4 mProj

uniform vec3 origin;
uniform float size;
uniform vec3 up;

void main() {
  VS_BEGIN
  vec4 wp = vec4(vertPos + origin, 1.0);
  vec3 look = normalize(eye - wp.xyz);
  vec3 right = cross(look, up);
  wp.xyz += size * uv.x * right;
  wp.xyz += size * uv.y * up;
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  VS_END
}
