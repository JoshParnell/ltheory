#include fragment
#include math

uniform vec2 size;
uniform vec4 color;
uniform float r1;
uniform float r2;
uniform float to;
uniform float tw;

const float bevel = 2.0;

void main() {
  float Tau = radians(360.0);
  vec2 p = size * (uv - 0.5);
  float r = length(p);
  vec2 dir = vec2(cos(Tau * to), sin(Tau * to));
  float rd = abs(r - 0.5 * (r1 + r2)) - 0.5 * (r2 - r1);
  float td = 0.5 * size.x * (acos(dot(dir, normalize(vec2(uv.x, 1.0-uv.y) - 0.5))) - 0.5 * Tau * tw);
  float d = max(0.0, length(max(vec2(0.0), vec2(rd, td) + bevel)) - bevel);

  float alpha = 0.0;
  alpha += 0.5 * exp(-max(0.0, d - 0.5));
  alpha += 0.4 * exp(-pow(0.3 * d, 0.75));
  vec3 c = 2.0 * color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
