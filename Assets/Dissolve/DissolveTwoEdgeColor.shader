Shader "Unlit/DissolveTwoEdgeColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        _EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
		_EdgeFirstColor("First Edge Color", Color) = (1,1,1,1)
        _EdgeSecondColor("Second Edge Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull off
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
                float2 uvMainTex : TEXCOORD0;
                float2 uvNoiseTex : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Threshold;

            float _EdgeLength;
			fixed4 _EdgeFirstColor;
            fixed4 _EdgeSecondColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               	fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;
				clip(cutout - _Threshold);

                if(cutout - _Threshold < _EdgeLength)
                {
                    float degree = (cutout - _Threshold) / _EdgeLength;
					return lerp(_EdgeFirstColor, _EdgeSecondColor, degree);
                }

				fixed4 col = tex2D(_MainTex, i.uvMainTex);
				return col;
            }
            ENDCG
        }
    }
}
