Shader "Unlit/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            float4x4 _CurrentInverseVP;
            float4x4 _LastVP;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));

                float4 NDC_Coord = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1);
                float4 World_Coord = mul(_CurrentInverseVP, NDC_Coord);
                World_Coord /= World_Coord.w;

                float4 lastNDC_Coord = mul(_LastVP, World_Coord);
                lastNDC_Coord /= lastNDC_Coord.w;

				float2 velocity = (NDC_Coord - lastNDC_Coord) / 2.0;

				float2 uv = i.uv;
				uv += velocity;

				int numSamples = 3;
				for(int index = 1; index < numSamples; index++, uv += velocity)
				{
					col += tex2D(_MainTex, uv);
				}
				col /= numSamples;

                return col;
            }
            ENDCG
        }
    }
}
