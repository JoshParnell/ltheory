#ifndef include_texturing
#define include_texturing

vec4 sampleTriplanar(sampler2D s, vec3 pos) {
  vec3 n = normalize(vertNormal);
  vec3 blend = n * n;
#ifdef HIGHQ
  return
    blend.x * texture2D(s, pos.yz) + 
    blend.y * texture2D(s, pos.zx) +
    blend.z * texture2D(s, pos.xy);
#else
  float maxBlend = max(blend.x, max(blend.y, blend.z));
  vec3 mask = vec3(step(maxBlend, blend.x),
                   step(maxBlend, blend.y),
                   step(maxBlend, blend.z));
  // vec3 ddx = dFdx(pos);
  // vec3 ddy = dFdy(pos);
  // vec2 dx = mask.x * ddx.yz + mask.y * ddx.xz + mask.z * ddx.xy;
  // vec2 dy = mask.x * ddy.yz + mask.y * ddy.xz + mask.z * ddy.xy;
  // float lod = max(0.0, 9.0 + 0.5 * log2(max(dot(dx, dx), dot(dy, dy))));
  vec2 coords = mask.x * pos.yz + mask.y * pos.xz + mask.z * pos.xy;
  return texture2D(s, coords);
#endif
}

vec3 sampleTriplanarBumpmap(sampler2D s, vec3 pos) {
  vec3 n = normalize(vertNormal);
  vec3 blend = n * n;
  vec3 tx = 2.0 * texture2D(s, pos.yz).xyz - 1.0;
  vec3 ty = 2.0 * texture2D(s, pos.zx).xyz - 1.0;
  vec3 tz = 2.0 * texture2D(s, pos.xy).xyz - 1.0;
  return blend.x * tx + blend.y * ty + blend.z * tz;
}

#endif
