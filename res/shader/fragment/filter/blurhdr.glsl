varying vec2 uv;

uniform sampler2D src;
uniform vec2 dir;
uniform vec2 size;
uniform int radius;
uniform float variance;

void main() {
  vec3 total = vec3(0.0);
  vec4 center = texture2D(src, uv);
  total += center.xyz * center.w;
  float tw = center.w;
  float v = variance * variance;

  for (int i = 1; i <= radius; ++i) {
    float fi = float(i);
    float w = exp(-(fi * fi) / v);
    vec2 delta = fi * (dir / size);
    vec4 c0 = texture2D(src, uv + delta);
    vec4 c1 = texture2D(src, uv - delta);
    float w0 = w * c0.w;
    float w1 = w * c1.w;
    total += w0 * c0.xyz;
    total += w1 * c1.xyz;
    tw += w0 + w1;
  }

  gl_FragColor = vec4(total / tw, tw);
}
