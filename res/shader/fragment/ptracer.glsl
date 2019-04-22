#version 450

varying vec2 uv;
uniform float time;
uniform vec2 mouse;
uniform vec2 res;
uniform vec3 right;
uniform vec3 up;
uniform vec3 look;
uniform vec3 eye;
uniform samplerCube mat1;

#define TAU 6.28318530718
#define PHI 1.61803398875
#define ZERO3 vec3(0.0, 0.0, 0.0)

float rand  (float x) { return fract(sin(x) * 41.3131571); }
float rand  (vec2 x)  { return rand(x.x + rand(x.y)); }
float genRand (inout float offset) { offset = rand(offset); return offset; }
float saturate (float x) { return clamp(x, 0.0, 1.0); }
vec2 saturate (vec2 x) { return clamp(x, vec2(0.0), vec2(1.0)); }
vec3 saturate (vec3 x) { return clamp(x, vec3(0.0), vec3(1.0)); }

struct Material { vec3 e; vec3 c; float rough; };
struct Hit      { float t; float t2; vec3 n; int id; };
struct Ray      { vec3 o; vec3 d; int src; };
struct Sphere   { Material mat; vec3 o; float r; };
struct Box      { Material mat; vec3 o; vec3  s; };

bool sphere ( in Ray r, inout Hit hit, vec3 so, float sr) {
  vec3 rel = r.o - so;
  float a = dot(r.d, r.d);
  float b = dot(r.d, rel);
  float c = dot(rel, rel) - (sr * sr);
  if (b*b < a*c) return false;

  float d = sqrt(b*b - a*c);
  float t0 = (-b - d) / a;
  float t1 = (-b + d) / a;
  float t = t0;
  if (t < 0.0 || t > hit.t) return false;
  
  hit.t = t;
  hit.t2 = t1;
  vec3 p = r.o + t * r.d;
  hit.n = normalize(p - so);
  return true;
}

bool box ( in Ray r, inout Hit hit, vec3 o, vec3 s ) {
  vec3 bt0 = ((o + s) - r.o) / r.d;
  vec3 bt1 = ((o - s) - r.o) / r.d;
  vec3 tMin = min(bt0, bt1);
  vec3 tMax = max(bt0, bt1);
  float t0 = max(tMin.x, max(tMin.y, tMin.z));
  float t1 = min(tMax.x, min(tMax.y, tMax.z));
  if (t0 >= t1 || t0 < 0.0 || t0 > hit.t) return false;

  hit.t = t0;
  hit.t2 = 0.0;
  vec3 p = r.o + t0 * r.d;
  vec3 sd = p - o;
  if (t0 == tMin.x)      hit.n = vec3(sign(sd.x), 0, 0);
  else if (t0 == tMin.y) hit.n = vec3(0, sign(sd.y), 0);
  else if (t0 == tMin.z) hit.n = vec3(0, 0, sign(sd.z));
  return true;
}

#if 1
SCENE_DESC
#else

  #define NSPHERES 24
  const float R = 1000.0;
  const float K = 10.0;
  const float D = R / 1.9 + K;
  Sphere spheres[NSPHERES] = {
    { { ZERO3, vec3(0.5), 100.00 }, D * vec3(0,  1,  PHI), R },
    { { ZERO3, vec3(0.5), 100.00 }, D * vec3(0, -1,  PHI), R },
    { { ZERO3, vec3(0.5), 0.005 }, D * vec3(0,  1, -PHI), R },
    { { ZERO3, vec3(0.5), 0.005 }, D * vec3(0, -1, -PHI), R },
    { { ZERO3, vec3(0.5), 100.00 }, D * vec3( 1,  PHI, 0), R },
    { { ZERO3, vec3(0.5), 100.00 }, D * vec3(-1,  PHI, 0), R },
    { { ZERO3, vec3(0.5), 0.1 }, D * vec3( 1, -PHI, 0), R },
    { { ZERO3, vec3(0.5), 0.1 }, D * vec3(-1, -PHI, 0), R },
    { { ZERO3, vec3(0.5), 100.0 }, D * vec3( PHI, 0,  1), R },
    { { ZERO3, vec3(0.5), 100.0 }, D * vec3( PHI, 0, -1), R },
    { { ZERO3, vec3(0.5), 0.005 }, D * vec3(-PHI, 0,  1), R },
    { { ZERO3, vec3(0.5), 0.005 }, D * vec3(-PHI, 0, -1), R },
    { { ZERO3, vec3(0.5), 0.20 }, vec3(0, 1e5 + 10, 0), 1e5 },

    { { ZERO3, vec3(1.0, 0.5, 0.5), 2.00 }, vec3(0,-10, 0), 2 },
    { { ZERO3, vec3(0.9, 0.5, 0.5), 1.00 }, vec3(0, -6, 0), 2 },
    { { ZERO3, vec3(0.8, 0.5, 0.5), 0.50 }, vec3(0, -2, 0), 2 },
    { { ZERO3, vec3(0.7, 0.5, 0.5), 0.20}, vec3(0,  2, 0), 2 },
    { { ZERO3, vec3(0.6, 0.5, 0.5), 0.18}, vec3(0,  6, 0), 2 },
    { { ZERO3, vec3(0.5, 0.5, 0.5), 0.05 }, vec3(0, 10, 0), 2 },

    { { ZERO3, vec3(0.5), 0.02 }, vec3(15, 6, 8), 4 },
    { { ZERO3, vec3(0.5), 0.02 }, vec3(-15, 6,-8), 4 },

    { {20.0 * vec3(1.00, 0.20, 0.05), vec3(1.0), 2.0 }, K * vec3( 0, -PHI, -1), 0.1 * K },
    { {50.0 * vec3(1.00, 0.30, 0.10), vec3(1.0), 2.0 }, K * vec3( PHI, 0,   1), 0.1 * K },
    { {10.0 * vec3(0.10, 0.20, 1.00), vec3(1.0), 2.0 }, vec3(0, 14, 15), 5 },
  };

  #define NBOXES 0

#endif

void scene ( in Ray r, inout Hit h ) {
  for (int i = 0; i < NSPHERES; ++i)
    if (r.src != i && sphere(r, h, spheres[i].o, spheres[i].r))
      h.id = i;

  for (int i = 0; i < NBOXES; ++i) {
    int id = i + NSPHERES;
    if (r.src != id && box(r, h, boxes[i].o, boxes[i].s))
      h.id = id;
  }
}

vec4 gather ( inout Ray r, inout float offset ) {
  vec3 atten = vec3(1.0, 1.0, 1.0);
  vec3 accum = vec3(0.0, 0.0, 0.0);
  float weight = 1.0;

  for (int i = 0; i < 32; ++i) {
    Hit h = { 1e30, 0, { 1, 0, 0 }, 0 };
    scene(r, h);
    if (h.t > 1e10) break;
    Material mat = h.id >= NSPHERES ? boxes[h.id - NSPHERES].mat : spheres[h.id].mat;
    accum += atten * mat.e;

    /* Russian Roulette. */ {
      if (i > 5) {
        float p = max(mat.c.x, max(mat.c.y, mat.c.z));
        if (rand(offset) <= p) break;
        atten /= p;
      }
    }
    atten *= mat.c;

    r.o = r.o + h.t * r.d;
    r.src = h.id;

    /* Unified roughness BRDF. Does not obey lambert. */
    float angle = TAU * genRand(offset);
    float z = 2.0 * genRand(offset) - 1.0;
    float x = sqrt(1.0 - z*z) * cos(angle);
    float y = sqrt(1.0 - z*z) * sin(angle);
    float l = mat.rough * sqrt(-log(1.0 - genRand(offset)));
    l *= 1.0 - pow(1.0 - abs(dot(r.d, h.n)), 5.0);
    r.d = reflect(r.d, h.n);
    r.d = r.d + l * vec3(x, y, z);
    r.d = normalize(r.d);
    if (dot(r.d, h.n) < 0.0) r.d *= -1.0;
  }

  return vec4(accum, 1.0);
}

void main () {
  float offset = rand(uv + time);
  float angle = TAU * genRand(offset);
  float r = sqrt(-2.0 * log(1.0 - genRand(offset)));
  float dx = 0.0;
  float dy = 0.0;
  for (int i = 0; i < 2; ++i) {
    dx += genRand(offset) - 0.5;
    dy += genRand(offset) - 0.5;
  }

  vec2 uvp = 2.0 * (uv * res + vec2(dx, dy)) / res  - 1.0;
  Ray ray = { eye, normalize(1.5 * look + uvp.x * right + uvp.y * up), -1 };
  vec4 c = gather(ray, offset);
  gl_FragColor = c;
}
