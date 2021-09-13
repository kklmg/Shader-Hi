Shader "Unlit/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeThreshold("Edge Threshold", Range(0.01, 1)) = 0.001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        
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
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_TexelSize;
            float _EdgeThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                

                o.uv[0] = v.uv;
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * float2(-1,1); 
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * float2(1,1); 
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * float2(-1,-1); 
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * float2(1,-1); 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex,i.uv[0]);

                float sampleLT = Linear01Depth(tex2D(_CameraDepthTexture, i.uv[0]));
                float sampleRT = Linear01Depth(tex2D(_CameraDepthTexture, i.uv[2]));
                float sampleBL = Linear01Depth(tex2D(_CameraDepthTexture, i.uv[3]));
                float sampleBR = Linear01Depth(tex2D(_CameraDepthTexture, i.uv[4]));

                float edge = 1.0;

                edge *= abs(sampleLT - sampleBR) < _EdgeThreshold ? 1.0 : 0.0;
                edge *= abs(sampleRT - sampleBL) < _EdgeThreshold ? 1.0 : 0.0;

                return lerp(0, color, edge); 
            }
            ENDCG
        }
    }
}
