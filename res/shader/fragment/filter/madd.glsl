varying vec2 uv;

uniform sampler2D src;
uniform vec4 add;
uniform vec4 mult;

void main() {
  gl_FragColor = mult * texture2D(src, uv) + add;
}
