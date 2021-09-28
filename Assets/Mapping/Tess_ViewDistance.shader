// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Tess_ViewDistance"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DisplacementTex("Displacement Texture", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 1)) = 0.2
        _Tess("Tessellation", Range(1, 32)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf BlinnPhong fullforwardshadows addshadow vertex:vert tessellate:tessFixed

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "Tessellation.cginc"

        sampler2D _MainTex;
        float _Displacement;
		sampler2D _DisplacementTex;
        float _Tess;

        struct appdata 
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

        struct Input
        {
            float2 uv_MainTex;
        };

 
        void vert(inout appdata v)
		{
			float d = tex2Dlod(_DisplacementTex, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
			v.vertex.xyz -= v.normal * d;
		}

        float4 tessFixed(appdata v0, appdata v1, appdata v2)
		{
            float minDist = 10.0;
            float maxDist = 25.0;


            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
		}

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Specular = 0.2;
			o.Gloss = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}


// float4 UnityDistanceBasedTess (float4 v0, float4 v1, float4 v2, float minDist, float maxDist, float tess)
// {
//     float3 f;
//     f.x = UnityCalcDistanceTessFactor (v0,minDist,maxDist,tess);
//     f.y = UnityCalcDistanceTessFactor (v1,minDist,maxDist,tess);
//     f.z = UnityCalcDistanceTessFactor (v2,minDist,maxDist,tess);

//     return UnityCalcTriEdgeTessFactors (f);
// }


// float UnityCalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess)
// {
//     float3 wpos = mul(unity_ObjectToWorld,vertex).xyz;
//     float dist = distance (wpos, _WorldSpaceCameraPos);
//     float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
//     return f;
// }

// float4 UnityCalcTriEdgeTessFactors (float3 triVertexFactors)
// {
//     float4 tess;
//     tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
//     tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
//     tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
//     tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
//     return tess;
// }
