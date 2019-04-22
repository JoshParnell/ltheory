varying vec2 uv;
varying vec3 pos;

uniform sampler2D texDiffuse;
uniform vec3 eye;

vec3 emix(vec3 a, vec3 b, float t) {
  return log(mix(exp(a), exp(b), t));
}

void main() {
  float dist = length(eye - pos);
  float freq = 1.0 / pow(dist, 0.75);
  float l2 = log2(freq) + 32.0;
  float f1 = pow(floor(l2), 2.0);
  float f2 = pow(floor(l2) + 1.0, 2.0);

  vec3 c = emix(
    texture2D(texDiffuse, f1 * uv).xyz,
    texture2D(texDiffuse, f2 * uv).xyz, fract(l2));

  c = sqrt(c * texture2D(texDiffuse, 4.0 * uv).xyz);
  c *= 0.5;

  gl_FragColor = vec4(c, 1.0);
}
