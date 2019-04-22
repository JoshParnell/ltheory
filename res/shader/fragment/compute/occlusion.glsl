varying vec2 uv;

uniform int sDim;
uniform float radius;
uniform sampler2D sPointBuffer;
uniform sampler2D sNormalBuffer;
uniform sampler2D vPointBuffer;
uniform sampler2D vNormalBuffer;

void main() {
  vec3 p = texture2D(vPointBuffer, uv).xyz;
  vec3 n = texture2D(vNormalBuffer, uv).xyz;

  float total = 0.0;
  for (int y = 0; y < sDim; ++y) {
    float v = (float(y) + 0.5) / float(sDim);
    for (int x = 0; x < sDim; ++x) {
      float u = (float(x) + 0.5) / float(sDim);

      vec4 sp = texture2D(sPointBuffer, vec2(u, v));
      vec4 sn = texture2D(sNormalBuffer, vec2(u, v));
      float area = sp.w;

      vec3 r = sp.xyz - p;
      float d = dot(r, r) + 1e-16;
      r *= inversesqrt(d);
      d /= radius;

      float value = 1.0 - inversesqrt(area / (d * d) + 1.0);
      value *= clamp(-dot(r, sn.xyz), 0.0, 1.0);
      value *= clamp(4.0 * dot(r, n), 0.0, 1.0);
      total += value;
    }
  }

  gl_FragColor.x = exp(-2.0 * sqrt(total));
}
