#define WINDOWS_TERMINAL

Texture2D shaderTexture : register(t0);
Texture2D image : register(t1);
SamplerState samplerState;

// --------------------
// INFO: Sometimes there are iTime and iResolution that irking us as well,
// remember to define it or change the name.
#if defined(WINDOWS_TERMINAL)
cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
};

#define TIME        Time
#define RESOLUTION  Resolution

#else

float time;
float2 resolution;

#define TIME        time
#define RESOLUTION  resolution

#endif
// --------------------

// --------------------
// GLSL => HLSL adapters
#define vec2  float2
#define vec3  float3
#define vec4  float4
#define mat2  float2x2
#define mat3  float3x3
#define fract frac
#define mix   lerp

float mod(float x, float y) {
  return x - y * floor(x/y);
}

vec2 mod(vec2 x, vec2 y) {
  return x - y * floor(x/y);
}

static const vec2 unit2 = vec2(1.0, 1.0);
static const vec3 unit3 = vec3(1.0, 1.0, 1.0);
static const vec4 unit4 = vec4(1.0, 1.0, 1.0, 1.0);

// --------------------

#define PI          3.141592654
#define PI_2        (0.5*3.141592654)
#define TAU         (2.0*PI)
#define ROT(a)      mat2(cos(a), sin(a), -sin(a), cos(a))
// INFO: So bcol is the original color.
static const vec3  bcol        = vec3(1.0, 0.27, 0.10)*sqrt(0.5);

static const float logo_radius = 0.25;
static const float logo_off    = 0.25;
static const float logo_width  = 0.10;
static const float3 chromaKey = float3(26.0f / 0xFF, 29.0f / 0xFF, 35.0f / 0xFF);
//
// PS_OUTPUT ps_main(in PS_INPUT In)
#if defined(WINDOWS_TERMINAL)
float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
#else
float4 ps_main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
#endif
{
  vec2 q = tex;
  vec2 p = -1.0 + 2.0*q;
  vec2 pp = p;
#if defined(WINDOWS_TERMINAL)
  p.y = -p.y;
#endif
  float ratioLengthWidth = RESOLUTION.x/RESOLUTION.y;
  p.x *= ratioLengthWidth;
  // FIXME: All I want here is just super Translucent, so we can leave effect for later matter.
  vec3 finalColor = (0.0,0.0,0.0);
  //vec3 finalColor = effect(p, pp);

  vec4 terminalColor = shaderTexture.Sample(samplerState, q);
  if(all(terminalColor.xyz == chromaKey))
  {
    return float4(0.05f, 0.0f, 0.0f, 0.05f);
  }
  vec4 sh = shaderTexture.Sample(samplerState, q-2.0*unit2/RESOLUTION.xy);
  float4 imageColor = image.Sample(samplerState, tex);
  finalColor = mix(finalColor, 0.0*unit3, sh.w);
  finalColor = mix(finalColor, terminalColor.xyz, terminalColor.w);

// INFO: Now I'm cooking here.
// lerp texture.
  // finalColor = lerp(imageColor, finalColor, 0.4);
  return vec4(finalColor, 0.0);
}
