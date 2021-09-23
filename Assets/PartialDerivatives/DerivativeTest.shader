Shader "Unlit/DerivativeTest"
{
    Properties
    {
        _Factor("Factor", Range(1, 100)) = 1
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
                float4 vertex : SV_POSITION;
            };

            float _Factor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; 
                return o;
            }

            float Myfwidth(float value)
            {
                float _ddx = ddx(value);
                float _ddy = ddy(value);

                return sqrt(_ddx * _ddx + _ddy * _ddy);
                //return abs(ddx(value)) + abs(ddy(value));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //calculate the change of the uv coordinate to the next pixel
                float derivative = fwidth(i.uv) * _Factor;

                //transform derivative to greyscale color
                fixed4 col = float4(derivative.xxx , 1);
                
                return col;
            }
            ENDCG
        }
    }
}
