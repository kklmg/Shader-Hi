Shader "Custom/PerlinNoise"
{
    Properties
    {
        _CellSize ("Cell Size", Range(0,10)) = 0.1
        _ScrollSpeed ("Scroll Speed", Range(0, 1)) = 1
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
        float _ScrollSpeed;

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

        // float perlinNoise(float2 value)
        // {
            //     float2 lowerLeftDirection = rand2dTo2d(float2(floor(value.x), floor(value.y))) * 2 - 1;
            //     float2 lowerRightDirection = rand2dTo2d(float2(ceil(value.x), floor(value.y))) * 2 - 1;
            //     float2 upperLeftDirection = rand2dTo2d(float2(floor(value.x), ceil(value.y))) * 2 - 1;
            //     float2 upperRightDirection = rand2dTo2d(float2(ceil(value.x), ceil(value.y))) * 2 - 1;

            //     float2 fraction = frac(value);

            //     float2 lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - float2(0, 0));
            //     float2 lowerRightFunctionValue = dot(lowerRightDirection, fraction - float2(1, 0));
            //     float2 upperLeftFunctionValue = dot(upperLeftDirection, fraction - float2(0, 1));
            //     float2 upperRightFunctionValue = dot(upperRightDirection, fraction - float2(1, 1));

            //     float interpolatorX = easeInOut(fraction.x);
            //     float interpolatorY = easeInOut(fraction.y);

            //     float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
            //     float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);


            //     float noise = lerp(lowerCells, upperCells, interpolatorY);
            //     return noise;
        // }

        float perlinNoise(float3 value)
        {
            float3 fraction = frac(value);

            float interpolatorX = easeInOut(fraction.x);
            float interpolatorY = easeInOut(fraction.y);
            float interpolatorZ = easeInOut(fraction.z);

            float cellNoiseZ[2];
            [unroll]
            for(int z=0;z<=1;z++)
            {
                float cellNoiseY[2];
                [unroll]
                for(int y=0;y<=1;y++)
                {
                    float cellNoiseX[2];
                    [unroll]
                    for(int x=0;x<=1;x++)
                    {
                        float3 cell = floor(value) + float3(x, y, z);
                        float3 cellDirection = rand3dTo3d(cell) * 2 - 1;
                        float3 compareVector = fraction - float3(x, y, z);
                        cellNoiseX[x] = dot(cellDirection, compareVector);
                    }
                    
                    cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
                }
                cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
            }

            float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
            return noise;
        }

        // void surf (Input i, inout SurfaceOutputStandard o)
        // {
            //     float value = i.worldPos.x / _CellSize;
            //     float noise = gradientNoise(value);
            
            //     float dist = abs(noise - i.worldPos.y);
            //     float pixelHeight = fwidth(i.worldPos.y);
            //     float lineIntensity = smoothstep(2*pixelHeight, pixelHeight, dist);
            //     o.Albedo = lerp(1, 0, lineIntensity);
        // }

        void surf (Input i, inout SurfaceOutputStandard o) 
        {
            float3 value = i.worldPos / _CellSize;
			value.z += _Time.z * _ScrollSpeed;
			//get noise and adjust it to be ~0-1 range
			float noise = perlinNoise(value) + 0.5;

			noise = frac(noise * 6);

			float pixelNoiseChange = fwidth(noise);

			float heightLine = smoothstep(1-pixelNoiseChange, 1, noise);
			heightLine += smoothstep(pixelNoiseChange, 0, noise);

			o.Albedo = heightLine;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
