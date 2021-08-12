Shader "Unlit/TilingNoise"
{
    Properties
    {
        _CellSize ("Cell Size", Range(0, 2)) = 2
        _Period ("Repeat every X cells", Vector) = (4, 4, 0, 0)
        [IntRange]_Roughness ("Roughness", Range(1, 8)) = 3
        _Persistance ("Persistance", Range(0, 1)) = 0.4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "WhiteNoise.cginc"

        //global shader variables
        #define OCTAVES 4 

        float _CellSize;
        float _Roughness;
        float _Persistance;

        //global shader variables
        float _Amplitude;

        //global shader variables
        float2 _Period;

        struct Input
        {
            float3 worldPos;
        };

        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)


        float2 modulo(float2 divident, float2 divisor)
        {
            float2 positiveDivident = divident % divisor + divisor;
            return divident % divisor;
        }
        
        
        float perlinNoise_2D(float2 value, float2 period)
        {
            float2 cellsMimimum = floor(value);
            float2 cellsMaximum = ceil(value);

            cellsMimimum = modulo(cellsMimimum, period);
            cellsMaximum = modulo(cellsMaximum, period);

            //generate random directions
            float2 lowerLeftDirection = rand2dTo2d(float2(cellsMimimum.x, cellsMimimum.y)) * 2 - 1;
            float2 lowerRightDirection = rand2dTo2d(float2(cellsMaximum.x, cellsMimimum.y)) * 2 - 1;
            float2 upperLeftDirection = rand2dTo2d(float2(cellsMimimum.x, cellsMaximum.y)) * 2 - 1;
            float2 upperRightDirection = rand2dTo2d(float2(cellsMaximum.x, cellsMaximum.y)) * 2 - 1;

            //rest of the function unchanged

            float2 fraction = frac(value);

            float2 lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - float2(0, 0));
            float2 lowerRightFunctionValue = dot(lowerRightDirection, fraction - float2(1, 0));
            float2 upperLeftFunctionValue = dot(upperLeftDirection, fraction - float2(0, 1));
            float2 upperRightFunctionValue = dot(upperRightDirection, fraction - float2(1, 1));

            float interpolatorX = easeInOut(fraction.x);
            float interpolatorY = easeInOut(fraction.y);

            float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
            float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);


            float noise = lerp(lowerCells, upperCells, interpolatorY);
            return noise;
        }

        float sampleLayeredNoise_2D(float2 value)
        {
            float noise = 0;
            float frequency = 1;
            float factor = 1;

            [unroll]
            for(int i=0; i<OCTAVES; i++)
            {
                noise = noise + perlinNoise_2D(value * frequency + i * 0.72354, _Period * frequency) * factor;
                factor *= _Persistance;
                frequency *= _Roughness;
            }

            return noise;
        }


        void surf (Input i, inout SurfaceOutputStandard o) 
        {
            float2 value = i.worldPos.xz / _CellSize;
            //get noise and adjust it to be ~0-1 range
            float noise = sampleLayeredNoise_2D(value) + 0.5;

            o.Albedo = noise;
        }


        ENDCG
    }
    FallBack "Diffuse"
}
