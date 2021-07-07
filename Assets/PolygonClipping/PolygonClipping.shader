Shader "Unlit/PolygonClipping"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
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
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float2 _corners[1000];
            uniform uint _cornerCount;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;

                return o;
            }

            float isLeftOfLine(float2 pos, float2 linePoint1, float2 linePoint2)
            {
                //variables we need for our calculations
                float2 lineDirection = linePoint2 - linePoint1;
                float2 lineNormal = float2(-lineDirection.y, lineDirection.x);
                float2 toPos = pos - linePoint1;

                //which side the tested position is on
                float side = dot(toPos, lineNormal);
                side = step(0, side);
                return side;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // float2 linePoint1 = float2(-0.4, 0);
                // float2 linePoint2 = float2(0.4, 0.4);
                // float2 linePoint3 = float2(0.4, -0.4);

                // float outsideTriangle = isLeftOfLine(i.worldPos.xy, linePoint1, linePoint2);
                // outsideTriangle = outsideTriangle + isLeftOfLine(i.worldPos.xy, linePoint2, linePoint3);
                // outsideTriangle = outsideTriangle + isLeftOfLine(i.worldPos.xy, linePoint3, linePoint1);


                // clip(-outsideTriangle);
                // return outsideTriangle;


                float outsideTriangle = 0;

                [loop]
                for(uint index;index<_cornerCount;index++)
                {
                    outsideTriangle += isLeftOfLine(i.worldPos.xy, _corners[index], _corners[(index+1) % _cornerCount]);
                }

                clip(-outsideTriangle);
                return _Color;



            }
            ENDCG
        }
    }
}
