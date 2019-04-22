#include vertex

uniform mat4 mWorldView;

void main() {
  VS_BEGIN
  normal = normalize((mWorldIT * vec4(vertex_normal, 0)).xyz);
  vec4 v = vec4(vertex_position, 1.0);
  vec4 wp = mWorldView * v;
  pos = wp.xyz;
  gl_Position = mProj * wp;
  VS_END
}
