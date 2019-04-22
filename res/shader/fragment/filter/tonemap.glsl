#include filter
#include color
#include math
#include gamma
#include noise
#include bezier

uniform int hdrOut;

const float b = 1.25;
const float k = 2.30;

const float kVignetteStrength = 0.25;
const float kVignetteHardness = 32.0;

#define HDR 0
#define COLOR_GRADING 1
#define DESAT 0
#define VIGNETTE 1

void main() {
  vec4 cc = texture2D(src, uv);
  vec3 c = cc.xyz;
  c = gamma(c);

  #if VIGNETTE
    /* NOTE : Applying vignette *before* tonemap allows HDR color to leak into
              the vignette, which is a nice touch. */

    /* Vignetting. */ {
      vec2 uvp = vec2(1.0, 1.0) - 2.0 * abs(vec2(0.5, 0.5) - uv);
      c *= 1.0 - kVignetteStrength * exp(-kVignetteHardness * uvp.x);
      c *= 1.0 - kVignetteStrength * exp(-kVignetteHardness * uvp.y);
    }
  #endif
 
  #if HDR
    c /= pow(lum(c), mix(0.25, 0.0, lum(c)));
  #endif

  /* Expmap with contrast correction. */ {
    #if 0
      c = saturate(c);
    #else
      c = 1.0 - exp(-k * pow(c, 1.25 + c));
    #endif
  }

  #if COLOR_GRADING
    /* Bezier grading with screenspace variation. */ {
      c = beziernorm3(c,
        vec3(0.25, 0.20 + 0.1 * uv.x, 0.35 - 0.15 * uv.y),
        vec3(0.40, 0.50 - 0.20 * uv.y, 0.50),
        vec3(0.80 + 0.2 * uv.y, 0.80, 0.80 - 0.40 * sqrt(uv.x * uv.y))
      );
    }
  #endif

  #if DESAT
    /* Desaturate as lum -> 1 for 'more realistic' highlights. */ {
      vec3 hsl = toHSL(c);
      hsl.y = mix(hsl.y, 0.0, pow4(hsl.z));
      c = toRGB(hsl);
    }
  #endif

  #if HDR
    c = mix(c, vec3(lum(c)), lum(c));
  #endif

  /* Color dither & clamp */ {
    c -= (2.0 * noise3(noise(uv * 16.0)) - vec3(1.0)) / 256.0;
    c = min(vec3(1.0), max(vec3(0.0), c));
  }

  gl_FragColor = vec4(c, cc.w);
}
