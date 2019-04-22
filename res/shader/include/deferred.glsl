#include math

const float Material_SIZE       = 4.0;

const float Material_Diffuse = 0.0 / Material_SIZE;
const float Material_Metal   = 1.0 / Material_SIZE;
const float Material_Ice     = 2.0 / Material_SIZE;
const float Material_NoShade = 3.0 / Material_SIZE;

vec2 encodeNormal(vec3 n) {
  return 0.5 * (vec2(atan(n.y, n.x) / PI, n.z) + 1.0);
}

vec3 decodeNormal(vec2 n) {
  vec2 ang = 2.0 * n - 1.0;
  vec2 scth = vec2(sin(ang.x * PI), cos(ang.x * PI));
  vec2 scphi = vec2(sqrt(1.0 - ang.y * ang.y), ang.y);
  return vec3(scth.y * scphi.x, scth.x * scphi.x, scphi.y);
}

void setAlbedo(vec3 a) {
  gl_FragData[0].xyz = a;
}

void setAlpha(float alpha) {
  gl_FragData[0].w = alpha;
}

void setDepth() {
  gl_FragData[2].x = length(pos - eye);
}

void setNormal(vec3 n) {
  gl_FragData[1].xy = encodeNormal(n);
}

void setRoughness(float roughness) {
  gl_FragData[1].z = roughness;
}

void setMaterial(float m) {
  gl_FragData[1].w = m;
}
