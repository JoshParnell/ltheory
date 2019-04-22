#extension GL_EXT_gpu_shader4 : enable

/* TODO : The only thing we actually require is textureLod / textureCubeLod ?
          This seems to be supported on some drivers even when gpu_shader4 is
          not available. Determine precisely how to check for this feature! We
          absolutely want to use it if the driver supports it. */

#ifdef GL_EXT_gpu_shader4
#define HIGHQ
#else
#define LOWQ
#endif

/* TODO : As per above, I am forcing HIGHQ for the moment until we have a way
          to check precisely. */
#define HIGHQ

/* WARNING : Make sure to update Fcoef if farPlane is changed! */
const float farPlane  = 1.0e6;

/* NOTE : Fcoef = 2.0 / log2(farPlane + 1.0);
          AMD drivers complain due to non-constexpr if not folded. */
const float Fcoef = 0.10034332462;
