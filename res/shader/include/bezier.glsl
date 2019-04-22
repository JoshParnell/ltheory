#ifndef include_bezier
#define include_bezier

float bezier3(float t, float y1, float y2, float y3) {
  float y12 = mix(y1, y2, t), y23 = mix(y2, y3, t);
  return mix(y12, y23, t);
}

vec3 bezier3(vec3 t, vec3 y1, vec3 y2, vec3 y3) {
  vec3 y12 = mix(y1, y2, t), y23 = mix(y2, y3, t);
  return mix(y12, y23, t);
}

float bezier4(float t, float y1, float y2, float y3, float y4) {
  float y12 = mix(y1, y2, t), y23 = mix(y2, y3, t), y34 = mix(y3, y4, t);
  float y123 = mix(y12, y23, t), y234 = mix(y23, y34, t);
  return mix(y123, y234, t);
}

vec3 bezier4(vec3 t, vec3 y1, vec3 y2, vec3 y3, vec3 y4) {
  vec3 y12 = mix(y1, y2, t), y23 = mix(y2, y3, t), y34 = mix(y3, y4, t);
  vec3 y123 = mix(y12, y23, t), y234 = mix(y23, y34, t);
  return mix(y123, y234, t);
}

/* Actually a 5-point bezier, with 0.0 and 1.0 as fixed endpoints. */

float beziernorm3(float x, float y1, float y2, float y3) {
  float y01 = mix(0.0, y1, x), y12 = mix(y1, y2, x), y23 = mix(y2, y3, x), y34 = mix(y3, 1.0, x);
  float y012 = mix(y01, y12, x), y123 = mix(y12, y23, x), y234 = mix(y23, y34, x);
  float y0123 = mix(y012, y123, x), y1234 = mix(y123, y234, x);
  return mix(y0123, y1234, x);
}

vec3 beziernorm3(vec3 x, vec3 y1, vec3 y2, vec3 y3) {
  vec3 y01 = mix(vec3(0.0), y1, x), y12 = mix(y1, y2, x), y23 = mix(y2, y3, x), y34 = mix(y3, vec3(1.0), x);
  vec3 y012 = mix(y01, y12, x), y123 = mix(y12, y23, x), y234 = mix(y23, y34, x);
  vec3 y0123 = mix(y012, y123, x), y1234 = mix(y123, y234, x);
  return mix(y0123, y1234, x);
}

#endif
