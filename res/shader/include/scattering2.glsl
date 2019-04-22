#ifndef common_scattering2
#define common_scattering2

#define iSteps 16
#define jSteps 1
#define CLOUDS_ENABLED 0

uniform samplerCube cloudCube;
uniform sampler3D cloudNoise;
uniform float rPlanet;
uniform float rAtmo;

vec2 rsi(vec3 ro, vec3 rd, float sr) {
  float a = dot(rd, rd);
  float b = 2.0 * dot(rd, ro);
  float c = dot(ro, ro) - (sr * sr);
  float d = (b*b) - 4.0*a*c;
  if (d <= 0.0) return vec2(1e5,-1e5);
  return vec2(
    (-b - sqrt(d))/(2.0*a),
    (-b + sqrt(d))/(2.0*a)
  );
}

float getClouds(vec3 p, float h, float dist) {
  float base = 0.0;
  base = texture3D(cloudNoise, 1.7 * p.xyz + vec3(355)).x;
  base = max(base, texture3D(cloudNoise, 3.9 * p.xyz + vec3(1.333)).x);
  base = 1.0 - exp(-pow2(1.5 * max(0.0, base - 0.3)));
  float thresh = texture3D(cloudNoise, 11.0 * p.yxz + vec3(113)).x;
  float s2 = 0;
  s2 = texture3D(cloudNoise, 12.77 * p.xyz + vec3(113)).x;
  s2 += texture3D(cloudNoise, 128.0 * p.zyx + vec3(999.0)).x;
  s2 = pow4(s2);
  base = pow4(4.0 * base);
  float hMask = 1.0;
  float d = 0.0;
  d += base;
  d *= s2;
  d *= sqrt(smoothstep(1.0, 0.0, h / 0.0020 - 1.0));
  d *= sqrt(smoothstep(0.0, 1.0, h / 0.0005 - 1.0));
  d = saturate(d);
  return d;
}

vec4 integrateClouds(
  vec3 rd,
  vec3 ro,
  vec3 dSun,
  float iSun,
  float rPlanet,
  vec3 kRlh)
{
  const int cloudSteps = 32;
  const int cloudStepsSecondary = 1;

  vec3 color = vec3(0.0);
  float visibility = 1.0;

  /* TODO : Optimize by intersecting against bottom cloud layer. */
  vec2 tAtmo = rsi(ro, rd, rPlanet * (1.004));
  if (tAtmo.y < tAtmo.x)
    return vec4(0.0, 0.0, 0.0, 0.0);
  vec2 tPlanet = rsi(ro, rd, rPlanet);
  tAtmo.x = max(0.0, tAtmo.x);
  if (tPlanet.x < tPlanet.y && tPlanet.y > 0.0)
    tAtmo.y = min(tAtmo.y, tPlanet.x);

  /* Primary ray. */
  float iT = 0;
  float stepSize = (tAtmo.y - tAtmo.x) / float(cloudSteps);
  float stepWeight = 1.0 / ((tAtmo.y - tAtmo.x) * float(cloudSteps));
  float rdNoise = noise(rd);
  float t = tAtmo.x + rdNoise * stepSize;
  for (int i = 0; i < cloudSteps; i++) {
    if (t >= tAtmo.y || visibility < 0.1)
      break;
    vec3 p = ro + rd * t;
    float h = length(p) - rPlanet;
    float d = getClouds(p, h, tAtmo.x);

    if (d > 0.3) {
      vec3 c = mix(vec3(1.0, 0.95, 0.8), vec3(0.25, 0.3, 0.35), d);
      float NL = dot(normalize(p), -dSun);
      float phase = mix(exp(-pow(1.0 + NL, 4.0)), 1.0, 0.01);
      c *= exp(-0.1 * pow2(1.0 - phase) * kRlh);
      c *= pow2(d);
      c *= pow4(visibility);
      color += 128.0 * iSun * phase * c * stepSize;
    }

    visibility *= exp(-128.0 * d * stepSize);
    t += stepSize;
  }

  return vec4(color, 1.0 - visibility);
}

float phaseHG(vec3 rd, vec3 dSun, float g) {
  float u = dot(rd, dSun);
  float g2 = g * g;
  float c = (3.0 / (8.0 * PI)) * (1.0 - g2) / (2.0 + g2);
  return
    c * (1.0 + u * u) / pow(1.0 + g2 - 2.0 * g * u, 1.5);
}

vec4 atmosphere(
  vec3 rd,
  vec3 ro,
  vec3 dSun,
  float iSun,
  float rPlanet,
  float rAtmos,
  vec3 kRlh,
  float kMie,
  float shRlh,
  float shMie,
  float g)
{
  vec2 tAtmo = rsi(ro, rd, rAtmos);
  if (tAtmo.y < tAtmo.x)
    return vec4(0,0,0,0);
  vec2 tPlanet = rsi(ro, rd, rPlanet);
  tAtmo.x = max(0.0, tAtmo.x);
  if (tPlanet.x < tPlanet.y && tPlanet.y > 0.0)
    tAtmo.y = min(tAtmo.y, tPlanet.x);

  vec4 result = vec4(0.0);

  /* Atmospheric Scattering. */ {
    vec3 totalRlh = vec3(0.0);
    vec3 totalMie = vec3(0.0);
    float iOdRlh = 0.0;
    float iOdMie = 0.0;

    /* Primary ray. */
    float iT = 0;
    float stepSize = (tAtmo.y - tAtmo.x) / float(iSteps);
    for (int i = 0; i < iSteps; i++) {
      vec3 iPos = ro + rd * (tAtmo.x + iT + 0.5 * stepSize);
      float iHeight = length(iPos) - rPlanet;
      float iClouds = getClouds(iPos, iHeight, tAtmo.x);
      iClouds *= 16.0;

      /* Accumulate optical depth of primary ray. */
      float odStepRlh = exp(-iHeight / shRlh) * stepSize;
      float odStepMie = exp(-iHeight / shMie) * stepSize;

      iOdRlh += odStepRlh;
      iOdMie += odStepMie;

      /* March towards sun, gathering in-scattering with secondary ray. */
      vec2 jAtmo = rsi(iPos, dSun, rAtmos);
      float jStepSize = jAtmo.y / float(jSteps);
      float jT = 0;
      float jRlh = 0.0;
      float jMie = 0.0;
      for (int j = 0; j < jSteps; j++) {
        vec3 jPos = iPos + dSun * (jT + 0.5 * jStepSize);
        float jHeight = length(jPos) - rPlanet;
        float jClouds = getClouds(jPos, jHeight, tAtmo.x);
        jRlh += exp(-jHeight / shRlh) * jStepSize;
        jMie += exp(-jHeight / shMie) * jStepSize;
        jT += jStepSize;
      }

      /* Accumulate attenuated in-scattering. */
      vec3 attn = exp(-(kMie * (iOdMie + jMie) + kRlh * (iOdRlh + jRlh)));
      totalRlh += odStepRlh * attn;
      totalMie += odStepMie * attn;
      iT += stepSize;
    }

    /* Phase Functions. */
    float pRlh = phaseHG(rd, dSun, 0.0);
    float pMie = phaseHG(rd, dSun, g);

    /* Approximate the atmospheric alpha using total optical depth. */
    float alpha = avg(1.0 - exp(-(kMie * iOdMie + kRlh * iOdRlh)));

    /* Calculate final atmosphere color from accumulated lighting. */
    result = vec4(iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie), alpha);
  }

#if CLOUDS_ENABLED
  /* Clouds. */ {
    vec4 clouds = integrateClouds(rd, ro, dSun, iSun, rPlanet, kRlh);
    result = mix(result, vec4(clouds.xyz, 1.0), clouds.w);
  }
#endif

  return result;
}

const vec3 kRayleigh = 2.0 * vec3(5.5, 13.0, 22.4);
const float kMie = 5;
const float hRayleigh = 0.15;
const float hMie = 0.03;
const float pMie = 0.758;

vec4 atmosphereDefault(vec3 rd, vec3 ro) {
  float atmoScale = (rAtmo - rPlanet) / rAtmo;
  return atmosphere(
    rd,
    (ro / rPlanet),
    starDir,
    22.0,
    1.0,
    rAtmo / rPlanet,
    kRayleigh,
    kMie,
    atmoScale * hRayleigh,
    atmoScale * hMie,
    pMie
  );
}

#endif
