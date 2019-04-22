#extension GL_ARB_shader_texture_lod : require

#include fragment
#include gamma
#include texturing

uniform vec3 eye;
uniform sampler2D texDiffuse;
uniform sampler2D texNormal;
uniform sampler2D texSpec;
uniform samplerCube envMap;

void main() {
  vec3 N = normalize(normal);
  vec3 uvw = vertPos.xyz / 2.0;

  vec3 c = sampleTriplanar(texDiffuse, uvw).xyz;
  float spec = sampleTriplanar(texSpec, uvw).x;
  spec *= spec;

  #if 0
    vec3 bump = sampleTriplanarBumpmap(texNormal, uvw);
    vec3 Q1  = dFdx(pos), Q2 = dFdy(pos);
    vec2 st1 = dFdx(uv), st2 = dFdy(uv);
    vec3 T = normalize(Q1*st2.t - Q2*st1.t);
    vec3 B = normalize(Q2*st1.s - Q1*st2.s);
    mat3 TBN = mat3(T, B, N);
    N = normalize(TBN * bump);
  #endif

  vec3 V = normalize(pos - eye);
  vec3 R = normalize(reflect(V, N));
  vec3 H = normalize(V - R);

  vec3 env = textureCubeLod(envMap, R, mix(4.0, 0.0, spec)).xyz;
  c *= env;
  gl_FragColor = vec4(c, 1.0);
  FRAGMENT_CORRECT_DEPTH;
}
