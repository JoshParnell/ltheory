#include fragment
#include math

uniform vec2 p1;
uniform vec2 p2;
uniform vec2 origin;
uniform vec2 size;
uniform vec4 color;

void main() {
  vec2 uvp = uv;
  vec3 c = color.xyz;

  vec2 tp = uvp * size + origin;
  vec2 toPoint = tp - p1;
  vec2 dir = p2 - p1;
  vec2 n = normalize(dir);
  float l = length(dir);
  if (l <= 1e-6) {
    discard;
    return;
  }

  float projLength = clamp(dot(n, toPoint), 0.0, l);
  vec2 proj = n * projLength;
  float d = length(toPoint - proj);
  float t = saturate(1.0 - projLength / l);
  float alpha = 0.0;
  alpha += 0.8 * exp(-2.0 * max(0.0, d - 0.5));
  alpha += 0.2 * exp(-pow(0.2 * d, 0.75));

  alpha *= exp(-2.0 * (1.0 - t));
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
