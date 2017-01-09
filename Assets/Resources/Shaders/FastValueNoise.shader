Shader "Hidden/Fast Value Noise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    struct Input
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct Varyings
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    sampler2D _MainTex;
    sampler2D _LookupTexture;

    float4 _MainTex_TexelSize;

    Varyings vertex(Input input)
    {
        Varyings output;

        output.vertex = UnityObjectToClipPos(input.vertex.xyz);
        output.uv = input.uv;

#if UNITY_UV_STARTS_AT_TOP
        if (_MainTex_TexelSize.y < 0)
            output.uv.y = 1. - input.uv.y;
#endif

        return output;
    }

    float generateValueNoise(in float3 seed)
    {
        float3 integer = floor(seed);
        float3 fractional = frac(seed);

        fractional = 1. - fractional * fractional;
        fractional = 1. - fractional * fractional;

        float2 uv = (integer.xy + float2(37., 17.) * integer.z) + fractional.xy;
        float2 rg = tex2Dlod(_LookupTexture, float4((uv + .5) * .00390625, 0., 0.)).xy;

        return lerp(rg.x, rg.y, fractional.z);
    }

    float generateValueNoise(in float4 seed)
    {
        float4 integer = floor(seed);
        float4 fractional = frac(seed);

        fractional = 1. - fractional * fractional;
        fractional = 1. - fractional * fractional;

        float2 uv = (integer.xy + integer.z * float2(37., 17.) + integer.w * float2(59., 83.)) + fractional.xy;

        float4 rgba = tex2Dlod(_LookupTexture, float4((uv + .5) * .00390625, 0., 0.));
        return lerp(lerp(rgba.x, rgba.y, fractional.z), lerp(rgba.z, rgba.w, fractional.z), fractional.w);
    }

    float generateFractalNoise(in float3 seed)
    {
        float result = .5 * generateValueNoise(seed);
        seed *= 2.01;

        result += .25 * generateValueNoise(seed);
        seed *= 2.02;

        result += .125 * generateValueNoise(seed);
        seed *= 2.03;

        return result + .0625 * generateValueNoise(seed);
    }

    float generateFractalNoise(in float4 seed)
    {
        float result = .5 * generateValueNoise(seed);
        seed *= 2.01;

        result += .25 * generateValueNoise(seed);
        seed *= 2.02;

        result += .125 * generateValueNoise(seed);
        seed *= 2.03;

        return result + .0625 * generateValueNoise(seed);
    }

    float4 fragment(in Varyings input) : SV_Target
    {
        return generateFractalNoise(float4(_WorldSpaceCameraPos.xy + input.uv * 16., _WorldSpaceCameraPos.z, _Time.x * 5.));
    }
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            ENDCG
        }
    }
}
