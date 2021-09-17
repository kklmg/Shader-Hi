Shader "Unlit/Ghost"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GhostColor("Ghost Color", Color) = (1,1,1,1)      
        _GhostAlpha("Ghost Alpha", Range(0, 1)) = 1 

        _TranslateRange("Translate Range",Range(0,10)) = 5
        _TranslateSpeed("Translate Speed", Range(0, 50)) = 1 
        _TranslateDirection("Translate Direction",Vector) = (0, 0, 1, 0) 

        _ShakeAmplitude("Shake Amplitude", Range(0, 2)) = 0 
        _ShakeSpeed("Shake Speed", Range(0, 50)) = 1 
        _ShakeDir("Shake Direction", Vector) = (0, 0, 1, 0) 
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
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
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            fixed4 _GhostColor;
            float _GhostAlpha;

            float _TranslateRange;
            float  _TranslateSpeed;
            float4  _TranslateDirection;

            float _ShakeAmplitude;
            float _ShakeSpeed;
            float4 _ShakeDir;

            v2f vert (appdata v)
            {
                v2f o;
                
                //translate
                v.vertex += _TranslateRange * cos(_Time.y * _TranslateSpeed) * _TranslateDirection; 

                //shake
                float yOffset = (floor(v.vertex.x * 10) % 2) == 0 ? -0.5 : 0.5;
                v.vertex += _ShakeAmplitude * yOffset * sin(_Time.y * _ShakeSpeed) * _ShakeDir; 

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(tex2D(_MainTex, i.uv).rgb * _GhostColor, _GhostAlpha);
            }
            ENDCG
        }
    }
}
