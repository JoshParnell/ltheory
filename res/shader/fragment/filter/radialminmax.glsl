varying vec2 uv;

uniform sampler2D src;
uniform int mode;
uniform int radius;
uniform vec2 size;
uniform float variance;

float lum(vec3 c) {
  return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec2 saturate(vec2 x) {
  return clamp(x, vec2(0.0, 0.0), vec2(1.0, 1.0));
}

void main() {
  vec4 final = texture2D(src, uv);
  vec4 cMin = final; 
  vec4 cMax = final; 

  for (int y = -radius; y <= radius; ++y) {
  for (int x = -radius; x <= radius; ++x) {
    if ((x != 0 || y != 0)) {
      vec2 offset = vec2(float(x), float(y));
      vec2 coord = uv + offset / size;
      if (coord.x >= 0.0 && coord.x <= 1.0 && coord.y >= 0.0 && coord.y <= 1.0) {
        vec4 c = texture2D(src, coord);
        vec2 v = vec2(variance);
        float l = lum(c.xyz);
        // v *= saturate(vec2(1.0 - l, l));
        // vec2 w = exp(-pow2(vec2(length(offset)) / v));
        vec2 w = saturate(1.0 - 0.5 * vec2(length(offset)) / v);
        cMin = mix(cMin, min(c, cMin), w.x);
        cMax = mix(cMax, max(c, cMax), w.y);
        final += c;
      }
    }
  }}

  gl_FragColor = vec4(mode == 0 ? cMin : cMax);
}
