varying vec2 uv;

uniform sampler2D src;
uniform float hardness;
uniform float strength;

void main() {
  float a = 1.0;
  vec2 uvp = vec2(1.0, 1.0) - 2.0 * abs(vec2(0.5, 0.5) - uv);
  a *= 1.0 - strength * exp(-hardness * uvp.x);
  a *= 1.0 - strength * exp(-hardness * uvp.y);
  vec4 c = texture2D(src, uv);
  c.xyz *= a;
  gl_FragColor = c;
}
