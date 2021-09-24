Shader "Unlit/DrawCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [ShowAsVector2] _Center("Circle Center",vector)  = (0.5,0.5,0,0)
        _Radius ("Radius",Range(0,0.5)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Trqnsparent" }

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _Center;
            float _Radius;

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
                float x = abs(i.uv.x - _Center.x);
                float y = abs(i.uv.y - _Center.y); 
                float distance = sqrt(x*x + y*y);
                //float distance = x + y;

                float stepped = 0;
                stepped = 1 - step( _Radius,distance); 
                return stepped;
            }
            ENDCG
        }
    }
}
