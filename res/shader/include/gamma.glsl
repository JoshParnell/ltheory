#ifndef include_gamme
#define include_gamma

#define GAMMA_CORRECT 1
const float kGamma = 2.2;

#if GAMMA_CORRECT
  vec3 linear(vec3 c)  { return pow(c, vec3(kGamma)); }
  vec3 gamma(vec3 c)   { return pow(c, vec3(1.0 / kGamma)); }
  vec4 linear(vec4 c)  { return vec4(linear(c.xyz), c.w); }
  vec4 gamma(vec4 c)   { return vec4(gamma(c.xyz), c.w); }
#else
  vec3 linear(vec3 c)  { return c; }
  vec3 gamma(vec3 c)   { return c; }
  vec4 linear(vec4 c)  { return c; }
  vec4 gamma(vec4 c)   { return c; }
#endif

#endif
