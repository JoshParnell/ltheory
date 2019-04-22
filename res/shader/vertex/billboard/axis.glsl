#include vertex
#include math

#autovar vec3 eye
#autovar mat4 mView
#autovar mat4 mProj

uniform vec2 size;

void main() {
  VS_BEGIN
  vec4 wp = mWorld * vec4(vertPos, 1.0);
  vec3 toCam = normalize(eye - wp.xyz);
  vec3 look = normalize((mWorld * vec4(0, 0, 1, 0)).xyz);
  vec3 right = normalize(cross(toCam, look));
  wp.xyz += size.x * uv.x * right;
  wp.xyz += size.y * uv.y * look;
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  VS_END
}
