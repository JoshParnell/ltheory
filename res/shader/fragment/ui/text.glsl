#include fragment

uniform sampler2D glyph;
uniform vec4 color;

void main() {
  float alpha = sqrt(texture2D(glyph, uv).w);
  vec3 c = color.xyz;
  gl_FragColor = alpha * color.w * vec4(c, 1.0);
}
