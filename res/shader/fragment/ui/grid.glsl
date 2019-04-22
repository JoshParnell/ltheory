#include fragment

uniform vec4 color;
uniform vec2 size;

const float scale = 1.0;

float dfield(float d) {
  return exp(-2.0 * d * d) + 0.2 * exp(-pow(0.2 * d, 0.75));
}

void main() {
  vec4 c = color;
  const vec2 offset = vec2(0.0, 0.0);
  vec2 scale1 = 0.5 * size;
  const vec2 scale2 = vec2(1.0, 1.0);

  vec2 uvp = uv;
  vec2 p = scale * (2.0 * uvp - 1.0) * scale1 * scale2 + offset;
  uvp = abs(2.0 * uvp - 1.0);
  vec2 d1 = 16.0 * abs(2.0 * fract(p / 16.0 - 0.5) - 1.0);
  vec2 d2 = 64.0 * abs(2.0 * fract(p / 64.0 - 0.5) - 1.0);

  float mult = 1.5;
  mult += 6.0 * exp(-32.0 * max(0.0, length(abs(2.0 * fract(p / 16.0 - 0.5) - 1.0)) - 0.75 / 16.0));
  mult += 6.0 * exp(-128.0 * max(0.0, length(abs(2.0 * fract(p / 64.0 - 0.5) - 1.0)) - 0.75 / 64.0));
  mult +=
    0.5 * max(
      dfield(max(0.0, d1.x - 1.0 / 16.0)),
      dfield(max(0.0, d1.y - 1.0 / 16.0)));
  mult +=
    1.5 * max(
      dfield(max(0.0, d2.x - 1.0 / 64.0)),
      dfield(max(0.0, d2.y - 1.0 / 64.0)));

  float d = 1.0;
  mult += d;
  mult *= 0.25;

  mult *= 2.0 * exp(-2.0 * uv.y);

#if 0
  mult += 1.0 * exp(-sqrt(max(0.0, scale1.x * abs(uvp.x - 1.0) - 1.00)));
  mult += 1.0 * exp(-sqrt(max(0.0, scale1.x * abs(uvp.x + 1.0) - 1.00)));
  mult += 1.0 * exp(-sqrt(max(0.0, scale1.y * abs(uvp.y - 1.0) - 1.00)));
  mult += 1.0 * exp(-sqrt(max(0.0, scale1.y * abs(uvp.y + 1.0) - 1.00)));
#endif

  gl_FragColor = c * mult;
}
