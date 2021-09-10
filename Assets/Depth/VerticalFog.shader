Shader "Unlit/VerticalFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogColor("Fog Color", Color) = (1,1,1,1)
		_FogDensity("Fog Density", Float) = 1
		_StartY("Start Y", Float) = 0
		_EndY("End Y", Float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 frustumDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
			float4x4 _FrustumDir;
			fixed4 _FogColor;
			float _FogDensity;
			float _StartY;
			float _EndY;

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
                fixed4 col = tex2D(_MainTex, i.uv);

				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				float linearEyeDepth = LinearEyeDepth(depth);

				float3 worldPos = _WorldSpaceCameraPos + linearEyeDepth * i.frustumDir.xyz;

				float fogDensity = (worldPos.y - _StartY) / (_EndY - _StartY);
				fogDensity = saturate(fogDensity * _FogDensity);
				
				fixed3 finalColor = lerp(_FogColor, col, fogDensity).xyz;
				return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
