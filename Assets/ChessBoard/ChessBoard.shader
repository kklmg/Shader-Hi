Shader "Unlit/ChessBoard"
{
	Properties
	{
		_Scale("Pattern Size", Range(0,10)) = 1
		_EvenColor("Color 1", Color) = (0,0,0,1)
		_OddColor("Color 2", Color) = (1,1,1,1)
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

			float _Scale;

			float4 _EvenColor;
			float4 _OddColor;

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 adjustedWorldPos = floor(i.worldPos / _Scale);

				//add different dimensions
				float chessboard = floor(adjustedWorldPos.x) + floor(adjustedWorldPos.z) + floor(adjustedWorldPos.y);

				//divide it by 2 and get the fractional part, resulting in a value of 0 for even and 0.5 for odd numbers.
				chessboard = frac(chessboard * 0.5);

				//multiply it by 2 to make odd values white instead of grey
				chessboard *= 2;

				float4 color = lerp(_EvenColor, _OddColor, chessboard);

				//return chessboard;
				return color;
            }
            ENDCG
        }
    }
}
