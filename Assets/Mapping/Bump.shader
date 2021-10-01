﻿Shader "Unlit/Bump"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _DepthMap("Depth Map", 2D) = "bump" {}
        _Scale("Scale", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DepthMap;
            float4 _DepthMap_TexelSize;
            float _Scale;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =  v.texcoord;

                //float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w;
                //float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
				o.lightDir = mul(rotation, o.lightDir);

                return o;
            }

            float3 CalculateNormal(float2 uv)
			{
				float2 du = float2(_DepthMap_TexelSize.x * 0.5, 0);
				float u1 = tex2D(_DepthMap, uv - du);
				float u2 = tex2D(_DepthMap, uv + du);
				float3 tu = float3(1, 0, (u2 - u1) * _Scale);

				float2 dv = float2(0, _DepthMap_TexelSize.y * 0.5);
				float v1 = tex2D(_DepthMap, uv - dv);
				float v2 = tex2D(_DepthMap, uv + dv);
				float3 tv = float3(0, 1, (v2 - v1) * _Scale);

				return normalize(-cross(tv, tu)); 
			}
			

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);
				float3 normal = CalculateNormal(i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
				fixed3 diffuse = albedo.rgb * _LightColor0.rgb * saturate(dot(normal, i.lightDir));

				fixed4 Color = fixed4(ambient + diffuse, 1.0);
				return Color;
            }
            ENDCG
        }
    }
}
