Shader "Unlit/BlackHole"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RightX("Right X", Float) = 1
        _LeftX("Left X", Float) = -1
        _Control("Born Control", Range(0, 2)) = 0
        _BlackHolePos("Black Hole Position", Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _RightX;
            float _LeftX;
            float _Control;
            float4 _BlackHolePos;

            float GetNormalizedDist(float worldPosX)
            {
                float range = _RightX - _LeftX;
                float border = _RightX;

                float dist = abs(worldPosX - border);
                float normalizedDist = (dist / range);
                return normalizedDist;
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float4 toBlackHole = _BlackHolePos - worldPos;



                float normalizedDist = GetNormalizedDist(worldPos.x);
                float val = max(0, _Control - normalizedDist);
                worldPos.xyz += toBlackHole * val;

                

                o.worldPos = worldPos;
                o.vertex = UnityWorldToClipPos(o.worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(_RightX -i.worldPos.x);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
