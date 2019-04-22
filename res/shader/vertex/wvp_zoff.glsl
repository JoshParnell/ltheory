#include vertex

uniform float zOffset;

void main() {
  VS_BEGIN
  normal = normalize((mWorldIT * vec4(vertex_normal, 0)).xyz);
  vec4 v = vec4(vertex_position, 1.0);
  vec4 wp = mWorld * v;
  pos = wp.xyz;
  gl_Position = mProj * (mView * wp);
  gl_Position.z += zOffset;
  VS_END
}
