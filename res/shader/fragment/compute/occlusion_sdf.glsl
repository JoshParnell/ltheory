#include math
#include noise

varying vec2 uv;

uniform float radius;
uniform sampler2D points;
uniform sampler3D sdf;

const int kSamples = 1024;
const float kThresh = 0.3;

void main() {
  vec3 p = 0.5 * texture2D(points, uv).xyz + 0.5;
  float total = 0.0;

  float offset = 133.7 * noise(uv);

  for (int i = 0; i < kSamples; ++i) {
    float a = TAU * noise(float(i) + 3.0 + offset * 1.3);
    float z = 2.0 * noise(float(i) + offset) - 1.0;
    float x = sin(a) * sqrt(1.0 - z*z);
    float y = cos(a) * sqrt(1.0 - z*z);
    float r = radius * sqrt(noise(float(i) + 51.0 + offset * 1.5));
    float s = texture3D(sdf, p + r * vec3(x, y, z)).x;
    if (s < 0.0)
      total += 1.0;
  }

  total /= float(kSamples);
  total = max(0.0, (total - kThresh) / (1.0 - kThresh));
  total = 1.0 - total;
  total *= total;

  gl_FragColor.x = total;
}
