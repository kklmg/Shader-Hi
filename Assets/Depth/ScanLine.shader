Shader "Unlit/ScanLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor("Line Color", Color) = (0, 0.8, 0.2, 1)
		_LineWidth("Line Width", Range(0, 0.08)) = 0.05
		_CurValue("Current Value", Range(0, 0.9)) = 0
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            fixed4 _LineColor;
			float _LineWidth;
			float _CurValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 originalColor = tex2D(_MainTex, i.uv);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				float linear01Depth = Linear01Depth(depth);
				float v = saturate(abs(_CurValue - linear01Depth) / _LineWidth);
				return lerp(_LineColor, originalColor, v);
            }
            ENDCG
        }
    }
}
