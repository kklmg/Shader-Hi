Shader "Custom/PerlinNoise_Layered"
{
    Properties
    {
        _CellSize ("Cell Size", Range(0, 10)) = 2
        _Roughness ("Roughness", Range(1, 8)) = 3
        _Persistance ("Persistance", Range(0, 1)) = 0.4
        _Amplitude("Amplitude", Range(0, 10)) = 1
        _ScrollDirection("Scroll Direction", Vector) = (0, 1, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

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

        float2 _ScrollDirection;


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

        float perlinNoise_2D(float2 value)
        {
            float2 lowerLeftDirection = rand2dTo2d(float2(floor(value.x), floor(value.y))) * 2 - 1;
            float2 lowerRightDirection = rand2dTo2d(float2(ceil(value.x), floor(value.y))) * 2 - 1;
            float2 upperLeftDirection = rand2dTo2d(float2(floor(value.x), ceil(value.y))) * 2 - 1;
            float2 upperRightDirection = rand2dTo2d(float2(ceil(value.x), ceil(value.y))) * 2 - 1;

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

        float perlinNoise_3D(float3 value)
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

        float sampleLayeredNoise_2D(float2 value)
        {
            float noise = 0;
            float frequency = 1;
            float factor = 1;

            [unroll]
            for(int i=0; i<OCTAVES; i++)
            {
                noise = noise + perlinNoise_2D(value * frequency + i * 0.72354) * factor;
                factor *= _Persistance;
                frequency *= _Roughness;
            }

            return noise;
        }

        float sampleLayeredNoise_3D(float3 value)
        {
            float noise = 0;
            float frequency = 1;
            float factor = 1;

            [unroll]
            for(int i=0; i<OCTAVES; i++)
            {
                noise = noise + perlinNoise_3D(value * frequency + i * 0.72354) * factor;
                factor *= _Persistance;
                frequency *= _Roughness;
            }

            return noise;
        }

        void vert(inout appdata_full data)
        {
            //get real base position
			float3 localPos = data.vertex / data.vertex.w;

			//calculate new posiiton
			float3 modifiedPos = localPos;
			float2 basePosValue = mul(unity_ObjectToWorld, modifiedPos).xz / _CellSize + _ScrollDirection * _Time.y;
			float basePosNoise = sampleLayeredNoise_2D(basePosValue) + 0.5;
			modifiedPos.y += basePosNoise * _Amplitude;
			
			//calculate new position based on pos + tangent
			float3 posPlusTangent = localPos + data.tangent * 0.02;
			float2 tangentPosValue = mul(unity_ObjectToWorld, posPlusTangent).xz / _CellSize + _ScrollDirection * _Time.y;
			float tangentPosNoise = sampleLayeredNoise_2D(tangentPosValue) + 0.5;
			posPlusTangent.y += tangentPosNoise * _Amplitude;

			//calculate new position based on pos + bitangent
			float3 bitangent = cross(data.normal, data.tangent);
			float3 posPlusBitangent = localPos + bitangent * 0.02;
			float2 bitangentPosValue = mul(unity_ObjectToWorld, posPlusBitangent).xz / _CellSize + _ScrollDirection * _Time.y;
			float bitangentPosNoise = sampleLayeredNoise_2D(bitangentPosValue) + 0.5;
			posPlusBitangent.y += bitangentPosNoise * _Amplitude;

			//get recalculated tangent and bitangent
			float3 modifiedTangent = posPlusTangent - modifiedPos;
			float3 modifiedBitangent = posPlusBitangent - modifiedPos;

			//calculate new normal and set position + normal
			float3 modifiedNormal = cross(modifiedTangent, modifiedBitangent);
			data.normal = normalize(modifiedNormal);
			data.vertex = float4(modifiedPos.xyz, 1);
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

        // void surf (Input i, inout SurfaceOutputStandard o) 
        // {
            //     float3 value = i.worldPos / _CellSize;
            //     value.z += _Time.z * _ScrollSpeed;
            //     //get noise and adjust it to be ~0-1 range
            //     float noise = perlinNoise(value) + 0.5;

            //     noise = frac(noise * 6);

            //     float pixelNoiseChange = fwidth(noise);

            //     float heightLine = smoothstep(1-pixelNoiseChange, 1, noise);
            //     heightLine += smoothstep(pixelNoiseChange, 0, noise);

            //     o.Albedo = pixelNoiseChange;
        // }

        void surf (Input i, inout SurfaceOutputStandard o) 
        {
            o.Albedo = 1;
        }


        ENDCG
    }
    FallBack "Diffuse"
}
