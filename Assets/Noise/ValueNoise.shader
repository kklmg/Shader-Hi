Shader "Custom/ValueNoise"
{
    Properties
    {
        _CellSize ("Cell Size", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows 7on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "WhiteNoise.cginc"

        float _CellSize;

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

        float ValueNoise2d(float2 value)
        {
            float upperLeftCell = rand2dTo1d(float2(floor(value.x), ceil(value.y)));
            float upperRightCell = rand2dTo1d(float2(ceil(value.x), ceil(value.y)));
            float lowerLeftCell = rand2dTo1d(float2(floor(value.x), floor(value.y)));
            float lowerRightCell = rand2dTo1d(float2(ceil(value.x), floor(value.y)));

            float interpolatorX = easeInOut(frac(value.x));
            float interpolatorY = easeInOut(frac(value.y));

            float upperCells = lerp(upperLeftCell, upperRightCell, interpolatorX);
            float lowerCells = lerp(lowerLeftCell, lowerRightCell, interpolatorX);

            float noise = lerp(lowerCells, upperCells, interpolatorY);
            return noise;
        }

        float3 ValueNoise3d(float3 value)
        {
            float interpolatorX = easeInOut(frac(value.x));
            float interpolatorY = easeInOut(frac(value.y));
            float interpolatorZ = easeInOut(frac(value.z));

            float3 cellNoiseZ[2];
            [unroll]
            for(int z=0;z<=1;z++)
            {
                float3 cellNoiseY[2];
                [unroll]
                for(int y=0;y<=1;y++)
                {
                    float3 cellNoiseX[2];
                    [unroll]
                    for(int x=0;x<=1;x++)
                    {
                        float3 cell = floor(value) + float3(x, y, z);
                        cellNoiseX[x] = rand3dTo3d(cell);
                    }
                    cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
                }
                cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
            }
            float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
            return noise;
        }


        //one dimension
        // void surf (Input i, inout SurfaceOutputStandard o)
        // {
            //     float value = i.worldPos.x / _CellSize;
            //     float previousCellNoise = rand1dTo1d(floor(value));
            //     float nextCellNoise = rand1dTo1d(ceil(value));
            //     float interpolator = frac(value);
            //     interpolator = easeInOut(interpolator);
            //     float noise = lerp(previousCellNoise, nextCellNoise, interpolator);

            //     float dist = abs(noise - i.worldPos.y);
            //     float pixelHeight = fwidth(i.worldPos.y);
            //     float lineIntensity = smoothstep(0, pixelHeight, dist);
            //     o.Albedo = lineIntensity;
        // }

        //2d 
        // void surf (Input i, inout SurfaceOutputStandard o) 
        // {
        //     float2 value = i.worldPos.xy / _CellSize;
        //     float noise = ValueNoise2d(value);

        //     o.Albedo = noise;
        // }

        //3d
        void surf (Input i, inout SurfaceOutputStandard o) 
        {
            float3 value = i.worldPos.xyz / _CellSize;
            float3 noise = ValueNoise3d(value);

            o.Albedo = noise;
        }
        ENDCG 
    }
    FallBack "Diffuse"
}
