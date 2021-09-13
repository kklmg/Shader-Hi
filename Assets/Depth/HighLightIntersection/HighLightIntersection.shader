Shader "Unlit/HighLightIntersection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IntersectionColor("Intersection Color", Color) = (1,1,0,0)
        _IntersectionWidth("Intersection Width", Range(0, 1)) = 0.1
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
                float4 screenPos : TEXCOORD1;
                float eyeZ : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _CameraDepthTexture;
            fixed4 _IntersectionColor;
            float _IntersectionWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                /* ScreenPos.x / width  = (x/w * 0.5 + 0.5); 
                ScreenPos.y / height  = (y/w * 0.5 + 0.5); 
                =>
                ScreenPos.x / width * w  = (x * 0.5 + w * 0.5); 
                ScreenPos.y / height * w  = (y * 0.5 * projectionParams.x + w * 0.5); 
                */
                o.screenPos = ComputeScreenPos(o.vertex);

                // depth value in camera space
                COMPUTE_EYEDEPTH(o.eyeZ);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float ndcDepth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                float eyeDepth = LinearEyeDepth(ndcDepth);
                
                float halfWidth = _IntersectionWidth / 2;
                float diff = saturate(abs(i.eyeZ - eyeDepth) / halfWidth);

                fixed4 finalColor = lerp(_IntersectionColor, col, diff);
                return finalColor;
            }
            ENDCG
        }
    }
}
