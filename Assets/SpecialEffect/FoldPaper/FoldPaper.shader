Shader "Unlit/FoldPaper"
{
    Properties
    {
        _FrontTex ("Front Tex", 2D) = "white" {}
        _BackTex  ("Back Tex", 2D) = "white" {}
        _FoldPos ("Fold Pos", float) = 5
        _FoldAngle   ("Fold Angle", Range(1, 180)) = 90
        [Toggle(ENABLE_DOUBLE)] _DoubleFold ("Double Fold", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        
        LOD 100

        //Front Face
        Pass
        {
            ZWrite On
            CUll back

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature ENABLE_DOUBLE
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

            sampler2D _FrontTex;
            float4 _FrontTex_ST;
            float _FoldPos, _FoldAngle;

            v2f vert (appdata v)
            {
                float angle = _FoldAngle;
                float r = _FoldPos - v.vertex.x;

                #if ENABLE_DOUBLE
                    if(r <= 0)
                    angle = 360 - _FoldAngle;
                #else
                    if(r <= 0)
                    angle = 180;
                #endif

                v.vertex.x = _FoldPos + r * cos(angle * UNITY_PI / 180);
                v.vertex.y = r * sin(angle * UNITY_PI / 180);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FrontTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_FrontTex, i.uv);
                return col;
            }
            ENDCG
        }

        //Back Face
        Pass
        {
            ZWrite On
            CUll Front

            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature ENABLE_DOUBLE
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

            sampler2D _BackTex;
            float4 _BackTex_ST;
            float _FoldPos, _FoldAngle;

            v2f vert (appdata v)
            {
                float angle = _FoldAngle;
                float r = _FoldPos - v.vertex.x;

                #if ENABLE_DOUBLE
                    if(r <= 0)
                    angle = 360 - _FoldAngle;
                #else
                    if(r <= 0)
                    angle = 180;
                #endif

                v.vertex.x = _FoldPos + r * cos(angle * UNITY_PI / 180);
                v.vertex.y = r * sin(angle * UNITY_PI / 180);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BackTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_BackTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
