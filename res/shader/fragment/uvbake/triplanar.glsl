#include fragment
#include texturing
#include math

uniform sampler2D src;

void main() {
  const float scale = 1.0;
  vec3 uvw = sqrt(scale / 32.0) * abs(vertPos.xyz);
  vec3 c = sampleTriplanar(src, uvw).xyz;
  c *= pow2(sampleTriplanar(src, uvw * 4.0).xyz);
  c = sqrt(c);
  gl_FragColor = vec4(c, 1.0);
}
