Shader "Unlit/TriplanarMapping"
{
	//show values to edit in inspector
	Properties
	{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Sharpness("Blend Sharpness", Range(1, 64)) = 1
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
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Sharpness;

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

			inline float magnitude(float3 f3)
			{
				return sqrt(f3.x*f3.x + f3.y*f3.y + f3.z*f3.z);
			}


			inline float angleBetween(float3 colour, float3 original)
			{
				return acos(dot(colour, original) / magnitude(colour)*magnitude(original));
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
				 float3 up = float3(0,1,0);

				 float angle = angleBetween(i.normal, up);

				 if(angle>30) return fixed4(i.normal.xyz, 1);

				 float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
				 float2 uv_side = TRANSFORM_TEX(i.worldPos.zy, _MainTex);
				 float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);

				 fixed4 col_front = tex2D(_MainTex, uv_front);
				 fixed4 col_side = tex2D(_MainTex, uv_side);
				 fixed4 col_top = tex2D(_MainTex, uv_top);

				 float3 weights = i.normal;
				 weights = abs(weights);

				 weights = weights / (weights.x + weights.y + weights.z);

				 //weights = pow(weights, _Sharpness);

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