Shader "Unlit/TriplanarMapping"
{
	//show values to edit in inspector
	Properties
	{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_TopTex("Texture", 2D) = "white" {}
		_SideTex("Texture", 2D) = "white" {}
		_Sharpness("Blend Sharpness", Range(1, 64)) = 1
		_Angle("Angle",Range(0,180)) = 30
	}

	SubShader
	{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			CGPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			//texture and transforms of the texture
			sampler2D _TopTex;
			sampler2D _SideTex;
			float4 _TopTex_ST;
			float4 _SideTex_ST;

			float _Sharpness;
			float _Angle;


			fixed4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 normal : NORMAL;
			};


			inline float angleBetween(float3 from, float3 to)
			{
				return acos(clamp(dot(normalize(from), normalize(to)), -1.0, 1.0)) * 57.29578f;
			}

			

			v2f vert(appdata v)
			{			
				v2f o;
				//calculate the position in clip space to render the object
				o.position = UnityObjectToClipPos(v.vertex);
				//calculate world position of vertex   
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				//change UVs based on tiling and offset of texture
				o.worldPos = worldPos.xyz;

				float3 worldNormal = mul(v.normal, (float3x3)unity_ObjectToWorld);
				o.normal = normalize(worldNormal);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				 float2 uv_front;
				 float2 uv_side;
				 float2 uv_top;


				 fixed4 col_front;
				 fixed4 col_side;
				 fixed4 col_top;


				 if (angleBetween(i.normal, float3(0, 1, 0))<_Angle) 
				 {
					 uv_front = TRANSFORM_TEX(i.worldPos.xy, _TopTex);
					 uv_side = TRANSFORM_TEX(i.worldPos.zy, _TopTex);
					 uv_top = TRANSFORM_TEX(i.worldPos.xz, _TopTex);


					 col_front = tex2D(_TopTex, uv_front);
					 col_side = tex2D(_TopTex, uv_side);
					 col_top = tex2D(_TopTex, uv_top);
				 }
				 else
				 {
					 uv_front = TRANSFORM_TEX(i.worldPos.xy, _SideTex);
					 uv_side = TRANSFORM_TEX(i.worldPos.zy, _SideTex);
					 uv_top = TRANSFORM_TEX(i.worldPos.xz, _SideTex);

					 col_front = tex2D(_SideTex, uv_front);
					 col_side = tex2D(_SideTex, uv_side);
					 col_top = tex2D(_SideTex, uv_top);
				 }
				 
				

				 float3 weights = i.normal;
				 weights = abs(weights);

				 weights = weights / (weights.x + weights.y + weights.z);

				 weights = pow(weights, _Sharpness);

				 col_front *= weights.z;
				 col_side *= weights.x;
				 col_top *= weights.y;


				 fixed4 col = col_front + col_side + col_top;


				 col *= _Color;
			
				 return col;
			}

			ENDCG
		}
	}
		FallBack "Standard" //fallback adds a shadow pass so we get shadows on other objects
}