#include vertex

uniform vec4 viewport;

void main() {
  VS_BEGIN;
  normal = normalize(vertex_normal);
  vec4 v = vec4(vertex_position, 1.0);
  vec4 p = mProj * (mView * v);
  pos = p.xyz;
  p /= p.w;
  p.xy = mix(viewport.xy, viewport.zw, 0.5 + 0.5 * p.xy);
  p.z = 0.0;
  p.w = 1.0;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * p);
}
