Shader "Unlit/ForceField"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1,1,1,1)
        _RimPower("Rim Power", Range(0, 1)) = 1
        _IntersectionPower("Intersect Power", Range(0, 1)) = 0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite Off
        //Blend SrcAlpha OneMinusSrcAlpha

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
                float eyeZ : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldViewDir : TEXCOORD4;
            };

            //sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;
            
            sampler2D _CameraDepthTexture;

            float _RimPower;
            float _IntersectionPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.eyeZ);

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldDir(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(worldPos);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //highlight intersection
                float ndcDepth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                float eyeDepth = LinearEyeDepth(ndcDepth);
                float intersection = (1-saturate(abs(i.eyeZ - eyeDepth))) * _IntersectionPower;

                //highlight Edge
                float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(i.worldViewDir);
                float rim = 1 - saturate(dot(worldNormal,worldViewDir)) * _RimPower;

                
                float v = max (rim, intersection);
                return _MainColor * v;
            }
            ENDCG
        }
    }
}
