Shader "Unlit/AA_Step"
{
    Properties
    {

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

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //smooth version of step
            float AAStep(float compValue, float gradient)
            {
                float halfChange = fwidth(gradient) / 2;

                //base the range of the inverse lerp on the change over one pixel
                float lowerEdge = compValue - halfChange;
                float upperEdge = compValue + halfChange;

                //if(lowerEdge > gradient) return 0;
                //if(gradient > upperEdge) return 1;

                //do the inverse interpolation
                float stepped = (gradient - lowerEdge) / (upperEdge - lowerEdge);
                stepped = saturate(stepped);
                return stepped;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float stepped = AAStep(0.5, i.uv.x); 
                
                //convert to greyscale color for output
                fixed4 col = float4(stepped.xxx, 1);
                return col;
            }
            ENDCG
        }
    }
}
