#include fragment
#include math
#include noise

uniform vec4 color;
uniform float time;

void main() {
  vec3 N = normalize(normal);
  vec3 V = normalize(eye - pos);
  float alpha = 1.0;
  alpha *= uv.x;
  alpha *= 1.0 - abs(dot(N, V));
  alpha *= 1.0 - 0.1 * log(1.0 - noise(vec3(gl_FragCoord.xy, time)));
  alpha *= 1.0 + 0.2 * sin(radians(180.0) * gl_FragCoord.y);
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
