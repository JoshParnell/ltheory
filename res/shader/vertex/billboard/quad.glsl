#include vertex
#include math

#autovar vec3 eye
#autovar mat4 mView
#autovar mat4 mProj

uniform float size;

void main() {
  VS_BEGIN
  vec4 wp = mWorld * vec4(vertPos, 1.0);
  vec3 look = normalize(eye - wp.xyz);
  vec3 up = normalize(ortho(look));
  vec3 right = cross(look, up);
  wp.xyz += size * uv.x * right;
  wp.xyz += size * uv.y * up;
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  VS_END
}
