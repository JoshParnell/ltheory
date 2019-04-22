#ifndef include_fdm
#define include_fdm

#include texturing

const float kDefaultMaxFreq = 1.0;

float getFDMFrequency() {
  return kDefaultMaxFreq / pow(length(pos - eye), 0.75);
}

vec4 sampleFDM(sampler2D sampler, vec3 pos) {
  float frequency = getFDMFrequency();
  float freqHi = pow(2.0, ceil(log2(frequency)));
  float freqLo = freqHi * 0.5;
  return mix(
    sampleTriplanar(sampler, freqLo * pos),
    sampleTriplanar(sampler, freqHi * pos),
    frequency / freqLo - 1.0);
}

vec4 sampleFDMTexture(sampler2D sampler, vec2 uv) {
  float frequency = getFDMFrequency();
  float freqHi = pow(2.0, ceil(log2(frequency)));
  float freqLo = freqHi * 0.5;
  return mix(
    texture2D(sampler, uv * freqLo),
    texture2D(sampler, uv * freqHi),
    frequency / freqLo - 1.0);
}

vec3 sampleFDMBumpmap(sampler2D sampler, vec3 pos) {
  float frequency = getFDMFrequency();
  float freqHi = pow(2.0, ceil(log2(frequency)));
  float freqLo = freqHi * 0.5;
  return mix(
    sampleTriplanarBumpmap(sampler, freqLo * pos),
    sampleTriplanarBumpmap(sampler, freqHi * pos),
    frequency / freqLo - 1.0);
}

#endif
