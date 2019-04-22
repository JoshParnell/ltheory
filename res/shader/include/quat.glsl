#ifndef include_quat
#define include_quat

vec3 quatMul(vec4 q, vec3 v) {
  vec3 t = cross(q.xyz, v);
  return 
    2.0 * q.xyz * dot(q.xyz, v) +
    v * (2.0 * q.w * q.w - 1.0) +
    2.0 * t * q.w;
}

vec4 quatAxisAngle(vec3 axis, float angle) {
  angle *= 0.5;
  float s = sin(angle);
  return vec4(s * axis.x, s * axis.y, s * axis.z, cos(angle));
}

#endif
