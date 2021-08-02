Shader "Custom/PerlinNoise"
{
    Properties
    {
        _CellSize ("Cell Size", Range(0,10)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "WhiteNoise.cginc"

        sampler2D _MainTex;
        float _CellSize;

        struct Input
        {
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float gradientNoise(float value)
        {
            float fraction = frac(value);
            float interpolator = easeInOut(fraction);

            float previousCellInclination = rand1dTo1d(floor(value)) * 2 - 1;
            float previousCellLinePoint = previousCellInclination * fraction;

            float nextCellInclination = rand1dTo1d(ceil(value)) * 2 - 1;
            float nextCellLinePoint = nextCellInclination * (fraction-1);


            return lerp(previousCellLinePoint, nextCellLinePoint, interpolator);
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            float value = i.worldPos.x / _CellSize;
            float noise = gradientNoise(value);
            
            float dist = abs(noise - i.worldPos.y);
            float pixelHeight = fwidth(i.worldPos.y);
            float lineIntensity = smoothstep(2*pixelHeight, pixelHeight, dist);
            o.Albedo = lerp(1, 0, lineIntensity);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
