#include vertex

void main() {
  uv = gl_MultiTexCoord0.xy;
  pos = gl_Vertex.xyz;
  gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
}
