Shader "Unlit/AA_Step"
{
    Properties
    {

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

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                float gradient = i.uv.x;
                float halfChange = fwidth(gradient) / 2;

                float lowerEdge = 0.5 - halfChange;
                float upperEdge = 0.5 + halfChange;

                float stepped = smoothstep(lowerEdge, upperEdge, gradient);
                return float4(stepped.xxx, 1);
            }
            ENDCG
        }
    }
}
