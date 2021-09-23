Shader "Unlit/Squash"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Squash("Squash",Range(0,1)) = 1
        _TopY("Top Y", Float) = 0 //The top Y of the GameObject in world coord
        _BottomY("Bottom Y", Float) = 0 
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Squash;
            float  _TopY;
            float _BottomY;

            v2f vert (appdata v)
            {
                v2f o;

                float SquashY =  _BottomY +  (_TopY - _BottomY) * _Squash;
                float4 WorldPos =  mul(unity_ObjectToWorld,v.vertex);

                if(WorldPos.y > SquashY)
                {
                    WorldPos.y = SquashY;
                }

                o.vertex= UnityWorldToClipPos(WorldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
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
