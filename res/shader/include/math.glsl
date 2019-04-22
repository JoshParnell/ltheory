#ifndef common_math
#define common_math

#define TAU 6.28318530718
#define PI  3.14159265359
#define PI2 1.57079632679

float saturate(float x) {
  return clamp(x, 0.0, 1.0);
}

vec2 saturate(vec2 x) {
  return clamp(x, vec2(0.0, 0.0), vec2(1.0, 1.0));
}

vec3 saturate(vec3 x) {
  return clamp(x, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
}

vec4 saturate(vec4 x) {
  return clamp(x, vec4(0.0, 0.0, 0.0, 0.0), vec4(1.0, 1.0, 1.0, 1.0));
}

float avg(vec2 x) { return (x.x + x.y) / 2.0; }
float avg(vec3 x) { return (x.x + x.y + x.z) / 3.0; }
float avg(vec4 x) { return (x.x + x.y + x.z + x.w) / 4.0; }

float compress(float t, float p) {
  float m = 2.0 * abs(t - 0.5);
  float s = sign(t - 0.5);
  m = pow(m, p);
  return 0.5 + 0.5 * s * m;
}

float contrast(float x, float c) {
  return saturate((x - 0.5) * c + 0.5);
}

vec3 contrast(vec3 x, float c) {
  return vec3(contrast(x.x, c), contrast(x.y, c), contrast(x.z, c));
}

vec4 contrast(vec4 x, float c) {
  return vec4(contrast(x.x, c), contrast(x.y, c), contrast(x.z, c), contrast(x.w, c));
}

float emix(float a, float b, float t) {
  return exp((1.0 - t) * log(a) + t * log(b));
}

vec2 emix(vec2 a, vec2 b, float t) {
  return exp((1.0 - t) * log(a) + t * log(b));
}

vec3 emix(vec3 a, vec3 b, float t) {
  return exp((1.0 - t) * log(a) + t * log(b));
}

vec4 emix(vec4 a, vec4 b, float t) {
  return exp((1.0 - t) * log(a) + t * log(b));
}

float gain(float t, float p) {
  if (t < 0.5)
    return pow(2.0 * t, p) / 2.0;
  else
    return 1.0 - pow(1.0 - 2.0 * (t - 0.5), p) / 2.0;
}

float mapRange(float x0, float x1, float y0, float y1, float x) { return y0 + (y1 - y0) * saturate((x - x0) / (x1 - x0)); }
vec2  mapRange(float x0, float x1, vec2 y0, vec2 y1, float x)   { return y0 + (y1 - y0) * saturate((x - x0) / (x1 - x0)); }
vec3  mapRange(float x0, float x1, vec3 y0, vec3 y1, float x)   { return y0 + (y1 - y0) * saturate((x - x0) / (x1 - x0)); }
vec4  mapRange(float x0, float x1, vec4 y0, vec4 y1, float x)   { return y0 + (y1 - y0) * saturate((x - x0) / (x1 - x0)); }

float max3(float a, float b, float c) { return max(a, max(b, c)); }
vec2  max3(vec2 a, vec2 b, vec2 c)    { return max(a, max(b, c)); }
vec3  max3(vec3 a, vec3 b, vec3 c)    { return max(a, max(b, c)); }
vec4  max3(vec4 a, vec4 b, vec4 c)    { return max(a, max(b, c)); }
float min3(float a, float b, float c) { return min(a, min(b, c)); }
vec2  min3(vec2 a, vec2 b, vec2 c)    { return min(a, min(b, c)); }
vec3  min3(vec3 a, vec3 b, vec3 c)    { return min(a, min(b, c)); }
vec4  min3(vec4 a, vec4 b, vec4 c)    { return min(a, min(b, c)); }

float mixInv(float a, float b, float value) {
  return (value - a) / (b - a);
}

vec3 ortho(vec3 v) {
  return mix(vec3(v.z, 0.0, -v.x), vec3(v.y, -v.x, 0.0), abs(v.y));
}

float pow2(float x) { return x * x; }
vec2  pow2(vec2 x)  { return x * x; }
vec3  pow2(vec3 x)  { return x * x; }
vec4  pow2(vec4 x)  { return x * x; }

float pow3(float x) { return x * x * x; }
vec2  pow3(vec2 x)  { return x * x * x; }
vec3  pow3(vec3 x)  { return x * x * x; }
vec4  pow3(vec4 x)  { return x * x * x; }

float pow4(float x) { x *= x; x *= x; return x; }
vec2  pow4(vec2 x)  { x *= x; x *= x; return x; }
vec3  pow4(vec3 x)  { x *= x; x *= x; return x; }
vec4  pow4(vec4 x)  { x *= x; x *= x; return x; }

float pow8(float x) { x *= x; x *= x; x *= x; return x; }
vec2  pow8(vec2 x)  { x *= x; x *= x; x *= x; return x; }
vec3  pow8(vec3 x)  { x *= x; x *= x; x *= x; return x; }
vec4  pow8(vec4 x)  { x *= x; x *= x; x *= x; return x; }

float pow16(float x) { x *= x; x *= x; x *= x; x *= x; return x; }
vec2  pow16(vec2 x)  { x *= x; x *= x; x *= x; x *= x; return x; }
vec3  pow16(vec3 x)  { x *= x; x *= x; x *= x; x *= x; return x; }
vec4  pow16(vec4 x)  { x *= x; x *= x; x *= x; x *= x; return x; }


vec3 reject(vec3 v, vec3 u) {
  return v - u * dot(u, v);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
  axis = normalize(axis);
  float c = cos(angle);
  return c * v + cross(axis, v) * sin(angle) + axis * dot(axis, v) * (1.0 - c);
}

vec2 safeNorm(vec2 x) {
  float l = dot(x, x);
  return l > 1e-6 ? x / sqrt(l) : vec2(0.0);
}

vec3 safeNorm(vec3 x) {
  float l = dot(x, x);
  return l > 1e-6 ? x / sqrt(l) : vec3(0.0);
}

vec4 safeNorm(vec4 x) {
  float l = dot(x, x);
  return l > 1e-6 ? x / sqrt(l) : vec4(0.0);
}

float threshold(float f, float t) {
  return saturate((f - t) / (1.0 - t));
}

float cosp(float t) { return 0.5 + 0.5 * cos(t); }
float sinp(float t) { return 0.5 + 0.5 * sin(t); }

#endif
