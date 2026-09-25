#pragma once

// ACES tonemapper matching Unity's post processing (Post Processing Stack v2 / Core RP ACES.hlsl)
// Unity does: linear sRGB -> ACES2065-1 (AP0) -> AcesTonemap (approximated RRT + ODT RGBmonitor_100nits_dim) -> linear Rec.709
// Previously this used the Stephen Hill fit (ACESFitted), which differs noticeably in contrast, saturation and hue handling

#define GRAPHLIT_ACES_PI 3.14159265359
#define GRAPHLIT_ACES_HALF_MAX 65504.0

static const float3x3 GraphlitACES_sRGB_2_AP0 =
{
    0.4397010, 0.3829780, 0.1773350,
    0.0897923, 0.8134230, 0.0967616,
    0.0175440, 0.1115440, 0.8707040
};

static const float3x3 GraphlitACES_AP0_2_AP1_MAT =
{
     1.4514393161, -0.2365107469, -0.2149285693,
    -0.0765537734,  1.1762296998, -0.0996759264,
     0.0083161484, -0.0060324498,  0.9977163014
};

static const float3x3 GraphlitACES_AP1_2_XYZ_MAT =
{
     0.6624541811, 0.1340042065, 0.1561876870,
     0.2722287168, 0.6740817658, 0.0536895174,
    -0.0055746495, 0.0040607335, 1.0103391003
};

static const float3x3 GraphlitACES_XYZ_2_AP1_MAT =
{
     1.6410233797, -0.3248032942, -0.2364246952,
    -0.6636628587,  1.6153315917,  0.0167563477,
     0.0117218943, -0.0082844420,  0.9883948585
};

static const float3x3 GraphlitACES_D60_2_D65_CAT =
{
     0.98722400, -0.00611327, 0.0159533,
    -0.00759836,  1.00186000, 0.0053302,
     0.00307257, -0.00509595, 1.0816800
};

static const float3x3 GraphlitACES_XYZ_2_REC709_MAT =
{
     3.2409699419, -1.5373831776, -0.4986107603,
    -0.9692436363,  1.8759675015,  0.0415550574,
     0.0556300797, -0.2039769589,  1.0569715142
};

static const float3 GraphlitACES_AP1_RGB2Y = float3(0.272229, 0.674082, 0.0536895);

// RRT / ODT parameters
static const float GraphlitACES_RRT_GLOW_GAIN = 0.05;
static const float GraphlitACES_RRT_GLOW_MID = 0.08;
static const float GraphlitACES_RRT_RED_SCALE = 0.82;
static const float GraphlitACES_RRT_RED_PIVOT = 0.03;
static const float GraphlitACES_RRT_RED_HUE = 0.0;
static const float GraphlitACES_RRT_RED_WIDTH = 135.0;
static const float GraphlitACES_RRT_SAT_FACTOR = 0.96;
static const float GraphlitACES_ODT_SAT_FACTOR = 0.93;
static const float GraphlitACES_DIM_SURROUND_GAMMA = 0.9811;

float GraphlitACES_rgb_2_saturation(float3 rgb)
{
    const float TINY = 1e-4;
    float mi = min(min(rgb.r, rgb.g), rgb.b);
    float ma = max(max(rgb.r, rgb.g), rgb.b);
    return (max(ma, TINY) - max(mi, TINY)) / max(ma, 1e-2);
}

float GraphlitACES_rgb_2_yc(float3 rgb)
{
    const float ycRadiusWeight = 1.75;
    float r = rgb.x;
    float g = rgb.y;
    float b = rgb.z;
    float k = b * (b - g) + g * (g - r) + r * (r - b);
    k = max(k, 0.0); // Guard against precision issues; mathematically k >= 0
    float chroma = k == 0.0 ? 0.0 : sqrt(k);
    return (b + g + r + ycRadiusWeight * chroma) / 3.0;
}

float GraphlitACES_rgb_2_hue(float3 rgb)
{
    float hue;
    if (rgb.x == rgb.y && rgb.y == rgb.z)
        hue = 0.0; // Undefined hue for achromatic colors
    else
        hue = (180.0 / GRAPHLIT_ACES_PI) * atan2(sqrt(3.0) * (rgb.y - rgb.z), 2.0 * rgb.x - rgb.y - rgb.z);

    if (hue < 0.0) hue = hue + 360.0;

    return hue;
}

float GraphlitACES_center_hue(float hue, float centerH)
{
    float hueCentered = hue - centerH;
    if (hueCentered < -180.0) hueCentered = hueCentered + 360.0;
    else if (hueCentered > 180.0) hueCentered = hueCentered - 360.0;
    return hueCentered;
}

float GraphlitACES_sigmoid_shaper(float x)
{
    // Sigmoid function in the range 0 to 1 spanning -2 to +2
    float t = max(1.0 - abs(x / 2.0), 0.0);
    float y = 1.0 + (x >= 0.0 ? 1.0 : -1.0) * (1.0 - t * t);
    return y / 2.0;
}

float GraphlitACES_glow_fwd(float ycIn, float glowGainIn, float glowMid)
{
    float glowGainOut;

    if (ycIn <= 2.0 / 3.0 * glowMid)
        glowGainOut = glowGainIn;
    else if (ycIn >= 2.0 * glowMid)
        glowGainOut = 0.0;
    else
        glowGainOut = glowGainIn * (glowMid / ycIn - 1.0 / 2.0);

    return glowGainOut;
}

float3 GraphlitACES_XYZ_2_xyY(float3 XYZ)
{
    float divisor = max(dot(XYZ, (1.0).xxx), 1e-4);
    return float3(XYZ.xy / divisor, XYZ.y);
}

float3 GraphlitACES_xyY_2_XYZ(float3 xyY)
{
    float m = xyY.z / max(xyY.y, 1e-4);
    float3 XYZ = float3(xyY.xz, (1.0 - xyY.x - xyY.y));
    XYZ.xz *= m;
    return XYZ;
}

float3 GraphlitACES_darkSurround_to_dimSurround(float3 linearCV)
{
    float3 XYZ = mul(GraphlitACES_AP1_2_XYZ_MAT, linearCV);

    float3 xyY = GraphlitACES_XYZ_2_xyY(XYZ);
    xyY.z = clamp(xyY.z, 0.0, GRAPHLIT_ACES_HALF_MAX);
    xyY.z = pow(abs(xyY.z), GraphlitACES_DIM_SURROUND_GAMMA);
    XYZ = GraphlitACES_xyY_2_XYZ(xyY);

    return mul(GraphlitACES_XYZ_2_AP1_MAT, XYZ);
}

// Equivalent of Unity's AcesTonemap (non TONEMAPPING_USE_FULL_ACES path), input in ACES2065-1 (AP0)
float3 GraphlitAcesTonemap(float3 aces)
{
    // --- Glow module --- //
    float saturation = GraphlitACES_rgb_2_saturation(aces);
    float ycIn = GraphlitACES_rgb_2_yc(aces);
    float s = GraphlitACES_sigmoid_shaper((saturation - 0.4) / 0.2);
    float addedGlow = 1.0 + GraphlitACES_glow_fwd(ycIn, GraphlitACES_RRT_GLOW_GAIN * s, GraphlitACES_RRT_GLOW_MID);
    aces *= addedGlow;

    // --- Red modifier --- //
    float hue = GraphlitACES_rgb_2_hue(aces);
    float centeredHue = GraphlitACES_center_hue(hue, GraphlitACES_RRT_RED_HUE);
    float hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / GraphlitACES_RRT_RED_WIDTH));
    hueWeight *= hueWeight;

    aces.r += hueWeight * s * (GraphlitACES_RRT_RED_PIVOT - aces.r) * (1.0 - GraphlitACES_RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    float3 acescg = max(0.0, mul(GraphlitACES_AP0_2_AP1_MAT, aces));

    // --- Global desaturation --- //
    acescg = lerp(dot(acescg, GraphlitACES_AP1_RGB2Y).xxx, acescg, GraphlitACES_RRT_SAT_FACTOR.xxx);

    // Luminance fitting of RRT.a1.0.3 + ODT.Academy.RGBmonitor_100nits_dim.a1.0.3
    const float a = 278.5085;
    const float b = 10.7772;
    const float c = 293.6045;
    const float d = 88.7122;
    const float e = 80.6889;
    float3 x = acescg;
    float3 rgbPost = (x * (a * x + b)) / (x * (c * x + d) + e);

    // Apply gamma adjustment to compensate for dim surround
    float3 linearCV = GraphlitACES_darkSurround_to_dimSurround(rgbPost);

    // Apply desaturation to compensate for luminance difference
    linearCV = lerp(dot(linearCV, GraphlitACES_AP1_RGB2Y).xxx, linearCV, GraphlitACES_ODT_SAT_FACTOR.xxx);

    // Rendering space RGB to XYZ
    float3 XYZ = mul(GraphlitACES_AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(GraphlitACES_D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries (linear Rec.709 / sRGB)
    return mul(GraphlitACES_XYZ_2_REC709_MAT, XYZ);
}

// Linear sRGB in, linear sRGB out, same as Unity's post processing ACES tonemapper
half3 ACESFitted(half3 color)
{
    float3 aces = mul(GraphlitACES_sRGB_2_AP0, (float3)color);
    return (half3)GraphlitAcesTonemap(aces);
}
