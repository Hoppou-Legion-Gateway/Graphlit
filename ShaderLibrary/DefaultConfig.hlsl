// Graphlit Project Config
// Remove prefix // to enable

// Enable for android only
/*
#ifndef UNITY_PBS_USE_BRDF1
#define _EXAMPLE
#endif
*/

// Enable ACES Tonemapping (usually useful for android only)
// #define _ACES

// Enable AgX Tonemapping, requires https://github.com/meenphie/AgX-Tonemapping-Unity (com.meenphie.commons.profiles)
// Takes priority over ACES. Pick one profile/look:
// #define _AGX_BASE_CONTRAST
// #define _AGX_MEDIUM_HIGH_CONTRAST
// #define _AGX_HIGH_CONTRAST
// #define _AGX_VERY_HIGH_CONTRAST
// #define _AGX_MEDIUM_LOW_CONTRAST
// #define _AGX_LOW_CONTRAST
// #define _AGX_VERY_LOW_CONTRAST
// #define _AGX_PUNCHY
// #define _AGX_GREYSCALE
// #define _AGX_POWERFUL
// #define _AGX_HUE

// Enable Bakery MonoSH
// #define _BAKERY_MONOSH

// Enable Lightmapped Specular
// #define _LIGHTMAPPED_SPECULAR

// Enable Bicubic Lightmap Filtering
// #define _BICUBIC_LIGHTMAP

// Enable Bicubic Shadowmask Filtering
// #define _BICUBIC_SHADOWMASK

// Enable Non Linear Lightmap SH
// #define _NONLINEAR_LIGHTPROBESH

// Allow realtime directional shadows to affect specular occlusion
// #define SPECULAR_OCCLUSION_REALTIME_SHADOWS

// Skip compiling vertex light variants to reduce shader size
// #pragma skip_variants VERTEXLIGHT_ON

// Clustered Birp Toggles (https://github.com/z3y/ClusteredBIRP)
// #define _CBIRP
// #define _CBIRP_REFLECTIONS

// Enable ZH3
// #define ZH3

// Force soft shadows (for the add pass)
// #define SHADOWS_SOFT

// Force low shadow bias
// #define FORCE_LOW_SHADOW_BIAS

// built-in add pass light distance attenuation multiplier
// this might match the intensity of the default falloff better
// #define LIGHT_ATTENUATION_MULTIPLIER 2.0

// Use square falloff instead of the default unity light attenuation
// #define SQUARE_FALLOFF_ATTENUATION

// Use RGB channels from light cookies instead of only sampling the alpha
// Keep a fallback grayscale cookie in the alpha channel for other shaders
// #define COLORED_COOKIES

// UdonRP
// https://z3y.github.io/Graphlit/udonrp
// #define _UDONRP_ENVIRONMENT_PROBE
// #define _UDONRP_DIRECTIONAL_COOKIE

// Modify Final Color
/*
#define _MODIFY_FINAL_COLOR
void ModifyFinalColor(inout half4 color)
{

}
*/


// disable fog
// #define GRAPHLIT_DISABLE_FOG