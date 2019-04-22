#ifndef include_fog
#define include_fog

float getFog() {
  float depth = length(pos - eye) / 1000000.0;
  return 1.0 - exp(-depth);
}

vec3 getFogColor(vec3 V) {
  return textureCubeLod(irMap, V, 3.0).xyz;
}

vec3 applyFog(vec3 c, vec3 V) {
  return mix(c, getFogColor(V), getFog());
}

#endif
