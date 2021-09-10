Shader "Unlit/WaterFlooded"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaterColor("Water Color", Color) = (0,0,0.8,1)
        _WaterHeight("Water Height", Float) = 1
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
                float4 vertex : SV_POSITION;
                float4 frustumDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _WaterColor;
            float _WaterHeight;
            sampler2D _CameraDepthTexture;
            float4x4 _FrustumDir;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                int ix = (int)o.uv.x;
				int iy = (int)o.uv.y;

                // uv = (0,0) => frustumDir = bottomLeft
                // uv = (0,1) => frustumDir = bottomRight
                // uv = (1,0) => frustumDir = topLeft
                // uv = (1,1) => frustumDir = topRight
				o.frustumDir = _FrustumDir[ix + 2 * iy];

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                float linearEyeDepth = LinearEyeDepth(depth);

                float3 worldPos = _WorldSpaceCameraPos.xyz +  i.frustumDir * linearEyeDepth;
                
                if (worldPos.y < _WaterHeight)
                return lerp(col, _WaterColor, _WaterColor.a); 

                return col;
            }
            ENDCG
        }
    }
}
