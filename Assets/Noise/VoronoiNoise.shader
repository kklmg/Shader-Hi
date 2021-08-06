Shader "Custom/VoronoiNoise"
{
    Properties 
    {
        _CellSize ("Cell Size", Range(0, 2)) = 2
    }

    SubShader 
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        #include "WhiteNoise.cginc"

        float _CellSize;

        struct Input 
        {
            float3 worldPos;
        };

        float2 voronoiNoise(float2 value)
        {
            // float2 cell = floor(value);
            // float2 cellPosition = cell + rand2dTo2d(cell);
            // float2 toCell = cellPosition - value;
            // float distToCell = length(toCell);
            // return distToCell;
            

            float2 baseCell = floor(value);

            float minDistToCell = 10;
            float2 closestCell;
            [unroll]
            for(int x=-1; x<=1; x++)
            {
                [unroll]
                for(int y=-1; y<=1; y++)
                {
                    float2 cell = baseCell + float2(x, y);
                    float2 cellPosition = cell + rand2dTo2d(cell);
                    float2 toCell = cellPosition - value;
                    float distToCell = length(toCell);
                    if(distToCell < minDistToCell)
                    {
                        minDistToCell = distToCell;
                        closestCell = cell;
                    }
                }
            }
            float random = rand2dTo1d(closestCell);
            return float2(minDistToCell, random);
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            float2 value = i.worldPos.xy / _CellSize;
            float noise = voronoiNoise(value).y;
            float3 color = rand1dTo3d(noise);
            o.Albedo = color;
        }
        ENDCG
    }
    FallBack "Standard"
}
