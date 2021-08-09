Shader "Custom/VoronoiNoise_3D"
{
    Properties
    {
        _BorderColor ("Border Color", Color) = (0,0,0,1)
        _CellSize ("Cell Size", Range(0, 2)) = 2
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

        struct Input 
        {
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _CellSize;
        float3 _BorderColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float3 voronoiNoise(float3 value)
        {
            float3 baseCell = floor(value);

            //first pass to find the closest cell
            float minDistToCell = 10;
            float3 toClosestCell;
            float3 closestCell;
            [unroll]
            for(int x1=-1; x1<=1; x1++)
            {
                [unroll]
                for(int y1=-1; y1<=1; y1++)
                {
                    [unroll]
                    for(int z1=-1; z1<=1; z1++)
                    {
                        float3 cell = baseCell + float3(x1, y1, z1);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;
                        float distToCell = length(toCell);
                        if(distToCell < minDistToCell){
                            minDistToCell = distToCell;
                            closestCell = cell;
                            toClosestCell = toCell;
                        }
                    }
                }
            }

            //second pass to find the distance to the closest edge
            float minEdgeDistance = 10;
            [unroll]
            for(int x2=-1; x2<=1; x2++)
            {
                [unroll]
                for(int y2=-1; y2<=1; y2++)
                {
                    [unroll]
                    for(int z2=-1; z2<=1; z2++)
                    {
                        float3 cell = baseCell + float3(x2, y2, z2);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;

                        float3 diffToClosestCell = abs(closestCell - cell);
                        bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
                        if(!isClosestCell)
                        {
                            float3 toCenter = (toClosestCell + toCell) * 0.5;
                            float3 cellDifference = normalize(toCell - toClosestCell);
                            float edgeDistance = dot(toCenter, cellDifference);
                            minEdgeDistance = min(minEdgeDistance, edgeDistance);
                        }
                    }
                }
            }

            float random = rand3dTo1d(closestCell);
            return float3(minDistToCell, random, minEdgeDistance);
        }

        void surf (Input i, inout SurfaceOutputStandard o) 
        {
            float3 value = i.worldPos.xyz / _CellSize;
            float3 noise = voronoiNoise(value);

            float3 cellColor = rand1dTo3d(noise.y); 
            float valueChange = fwidth(value.z) * 0.5;
            float isBorder = 1 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise.z);
            float3 color = lerp(cellColor, _BorderColor, isBorder);
            o.Albedo = color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
