Shader "Unlit/PostProcessingDepthNormal"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _upCutoff ("up cutoff", Range(0,1)) = 0.7
        _topColor ("top color", Color) = (1,1,1,1)
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //the depth normals texture
            sampler2D _CameraDepthNormalsTexture;

            //matrix to convert from view space to world space
            float4x4 _viewToWorld;

            //effect customisation
            float _upCutoff;
            float4 _topColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                   //read depthnormal
                float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);

                //decode depthnormal
                float3 normal;
                float depth;
                DecodeDepthNormal(depthnormal, depth, normal);

                //get depth as distance from camera in units 
                depth = depth * _ProjectionParams.z;

                normal = mul((float3x3)_viewToWorld, normal);

                float up = dot(float3(0,1,0), normal);
                up = step(_upCutoff, up);
                float4 source = tex2D(_MainTex, i.uv);
                float4 col = lerp(source, _topColor, up * _topColor.a);
                return col;
            }
            ENDCG
        }
    }
}
