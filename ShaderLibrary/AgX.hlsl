#pragma once

// AgX tonemapping using the LUTs from https://github.com/meenphie/AgX-Tonemapping-Unity (com.meenphie.commons.profiles)
// Enable with one of the _AGX_<PROFILE/LOOK> defines in the project config (Assets/Settings/GraphlitConfig.hlsl)
// Sampling matches Post Processing Stack v2 External LUT mode: linear -> LogC -> 3D LUT -> linear

#if defined(_AGX_BASE_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutBaseContrast
#elif defined(_AGX_MEDIUM_HIGH_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutMediumHighContrast
#elif defined(_AGX_HIGH_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutHighContrast
#elif defined(_AGX_VERY_HIGH_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutVeryHighContrast
#elif defined(_AGX_MEDIUM_LOW_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutMediumLowContrast
#elif defined(_AGX_LOW_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutLowContrast
#elif defined(_AGX_VERY_LOW_CONTRAST)
    #define GRAPHLIT_AGX_LUT _AgXLutVeryLowContrast
#elif defined(_AGX_PUNCHY)
    #define GRAPHLIT_AGX_LUT _AgXLutPunchy
#elif defined(_AGX_GREYSCALE)
    #define GRAPHLIT_AGX_LUT _AgXLutGreyscale
#elif defined(_AGX_POWERFUL)
    #define GRAPHLIT_AGX_LUT _AgXLutPowerful
#elif defined(_AGX_HUE)
    #define GRAPHLIT_AGX_LUT _AgXLutHue
#endif

// The LUT texture is only bound when the AgX package is installed, otherwise skip tonemapping instead of sampling a missing texture
#if defined(GRAPHLIT_AGX_LUT) && defined(GRAPHLIT_AGX_PACKAGE)

#define GRAPHLIT_AGX

// LUTs are 32x32x32 (1024x32 strip imported as a 3D texture)
#define GRAPHLIT_AGX_LUT_SIZE 32.0

TEXTURE3D(GRAPHLIT_AGX_LUT);

// Alexa LogC (EI 1000), same as Post Processing Stack v2 LinearToLogC (non precise path)
float3 GraphlitAgX_LinearToLogC(float3 x)
{
    return 0.244161 * log10(5.555556 * x + 0.047996) + 0.386036;
}

half3 AgXTonemap(half3 color)
{
    float3 uvw = saturate(GraphlitAgX_LinearToLogC(max(0.0, (float3)color)));

    // Texel center remap, same as ApplyLut3D
    const float2 scaleOffset = float2(1.0 / GRAPHLIT_AGX_LUT_SIZE, GRAPHLIT_AGX_LUT_SIZE - 1.0);
    uvw = uvw * scaleOffset.yyy * scaleOffset.xxx + scaleOffset.xxx * 0.5;

    return (half3)SAMPLE_TEXTURE3D_LOD(GRAPHLIT_AGX_LUT, sampler_BilinearClamp, uvw, 0).rgb;
}

#endif
