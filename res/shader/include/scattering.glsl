#ifndef common_scattering
#define common_scattering

vec2 interSphere(vec4 sphere, vec3 ro, vec3 rd) {
  vec3 v = sphere.xyz - ro;
  float b = dot(rd, v);
  float d = b*b - dot(v, v) + sphere.w * sphere.w;
  return d >= 0.0 ? vec2(b - sqrt(d), b + sqrt(d)) : vec2(1.0e30);
}

uniform float atmoDensity;
uniform vec3 atmoTint;
uniform vec3 wavelength;
uniform vec3 scale;

const float kAtmoDensityMult = 1.0;
const float kAtmoScale = 0.05;
const float kOuterRadius = 1.05;

//vec3 kRayleigh = vec3(0.0025) / pow(vec3(0.65, 0.57, 0.475), vec3(4.0));
//vec3 kRayleigh = vec3(0.0025) / pow(vec3(0.45, 0.57, 0.65), vec3(4.0));
vec3 kRayleigh = 0.05629 * normalize(pow(vec3(0.2488, 0.4207, 0.8724), vec3(1.0)));
vec3 kMie = vec3(0.002);

const float kDepth = 0.125;
const float kRcpSamples = 1.0 / 16.0;

float phase(float x) {
  return exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + 6.25 * x))));
}

float hgPhase(float d, float g) {
  return
    1.5 * (1. - g*g) / (2.0 + g*g) * (1.0 + d*d) /
    pow(1.0 + g*g - 2.0*g*d, 1.5);
}

vec4 shadeAtmosphere(
  vec3 rd,
  vec3 near,
  vec3 far,
  vec3 starDir,
  float occlusion)
{
  vec3 c = vec3(0.0);
  float td = 0.0;
  float segMult = kAtmoDensityMult * atmoDensity * kRcpSamples * length(far - near) / kAtmoScale;
  for (float t = 0.5 * kRcpSamples; t < 1.0; t += kRcpSamples) {
    vec3 p = mix(near, far, t);
    float density = exp(-((length(p) - 1.0) / kAtmoScale) / kDepth);
    float inScatter = density * phase(1.0 - dot(starDir, normalize(p)));
    c += density * exp(-3.0 * kDepth * segMult * inScatter * (wavelength * kRayleigh + kMie));
    td += density * exp(-3.0 * kDepth * segMult * inScatter);
  }

  c *= atmoTint * starColor;
  float d = dot(rd, starDir);
  float rayPhase = 1.0 - occlusion;
  float miePhase = (1.0 - sqrt(occlusion)) * hgPhase(d, 0.75);
  c *= rayPhase * wavelength * kRayleigh + miePhase * kMie;
  c *= sqrt(c / max(1e-6, lum(c)));
  return vec4(c, td);
}

vec4 getScattering(vec3 center, vec3 ro, vec3 rd, float depth) {
  float rInner = scale.x;
  float rOuter = rInner * kOuterRadius;
  vec2 inner = interSphere(vec4(center, rInner), ro, rd);
  vec2 outer = interSphere(vec4(center, rOuter), ro, rd);
  if (inner.x < 0.0 && inner.y > 0.0)
    return vec4(0.0);
  outer.x = max(outer.x, 0.0);
  if (inner.x > 0.0)
    outer.y = min(outer.y, inner.x);
  vec3 tn = ((ro + rd * outer.x) - center) / rInner;
  vec3 tf = ((ro + rd * outer.y) - center) / rInner;
  return shadeAtmosphere(rd, tn, tf, -starDir, 0.0);
}

vec4 getScatteringInside(vec3 center, vec3 ro, vec3 rd, float depth) {
  float rInner = scale.x;
  float rOuter = rInner * kOuterRadius;
  vec2 innerT = interSphere(vec4(center, rInner), ro, rd);
  vec2 outerT = interSphere(vec4(center, rOuter), ro, rd);

  vec3 near;
  vec3 far;

  if (max(outerT.x, outerT.y) < 0.0)
  return vec4(0.0);

  /* Space. */
  if (outerT.x > 0.0 && outerT.x < farPlane) {
    near = (ro + rd * outerT.x) / scale.x;
    far = (ro + rd * min(outerT.y, innerT.x)) / scale.x;
  } else if (outerT.x < 0.0 && outerT.y > 0.0) {
    near = ro / scale.x;
    far = (ro + rd * min(outerT.y, depth)) / scale.x;
  } else {
    return vec4(0.0);
  }

  return shadeAtmosphere(rd, near, far, -starDir, 0.0);
}

#endif
