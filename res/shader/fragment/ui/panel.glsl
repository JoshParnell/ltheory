#include fragment
#include math

uniform float padding;
uniform vec2 size;
uniform vec4 color;
uniform float innerAlpha;
uniform float bevel;

float dbox(vec2 p, vec2 s, float b) {
  return length(max(vec2(0.0, 0.0), abs(p) - (s - 2.0 * vec2(b, b)))) - b;
}

void main() {
  vec3 c;
  c = color.xyz * (1.25 - 0.5 * uv.y);
  float x = size.x * (2.0 * uv.x - 1.0);
  float y = size.y * (2.0 * uv.y - 1.0);

  float d = dbox(vec2(x, y), size + bevel - 2.0 * padding, bevel);
  float k = exp(-max(0.0, d));
  float mult = 0.0;

  /* Inner opacity. */ {
    mult += innerAlpha * k;
  }

  /* Shadow. */ {
    mult += 0.75 * saturate(exp(-pow(0.2 * max(0.0, d), 0.75)) - k);
  }

  mult *= color.w;
  mult = saturate(mult);

  /* Gradient. */ {
    c *= 0.8 + 0.4 * exp(-2.0 * uv.y);
  }

  c += 0.3 * vec3(0.1, 0.5, 1.0) * exp(-8.0 * length(uv - vec2(0.5, 0.0)));
  c = mix(c, vec3(0.005, 0.005, 0.005), 1.0 - exp(-2.0 * max(0.0, d)));

  gl_FragColor = vec4(c, mult);
}
