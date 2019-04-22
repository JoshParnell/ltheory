#include filter

uniform int radius;
uniform float sigma;

void main() {
  vec4 c = vec4(0.0);
  float tw = 0.0;

  for (int y = -radius; y <= radius; ++y)
  for (int x = -radius; x <= radius; ++x) {
    vec2 offset = vec2(float(x), float(y));
    float w = exp(-dot(offset, offset) / (sigma * sigma));
    c += w * texture2D(src, uv + offset / size);
    tw += w;
  }

  gl_FragColor = c / tw;
}
