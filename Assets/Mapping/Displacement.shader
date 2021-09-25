Shader "Custom/Displacement"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DisplacementTex("Displacement Texture", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf BlinnPhong fullforwardshadows addshadow vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _Displacement;
		sampler2D _DisplacementTex;

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
