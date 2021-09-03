Shader "Unlit/ShowDepthBuffer01"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _FrameColor  ("Frame Color",Color) = (1,1,1,1)
        _FrameWidth ("Frame Width",float) = 10
        _ScreenSpiltFactor ("Screen Spilt Factor",Range(0.0,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            // ZWrite off;

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 srcPos: TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _FrameColor;
            float _FrameWidth;

            float _ScreenSpiltFactor;


            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.srcPos = ComputeScreenPos(o.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                int width = _ScreenParams.x;
                int height = _ScreenParams.y;
                int RGBWidth = width * _ScreenSpiltFactor;
                int depthWidth = width- RGBWidth;
                int targetHeight = height - _FrameWidth*2;

                float x =  width * i.uv.x;
                float y =  height * i.uv.y;

                if(x < _FrameWidth || y < _FrameWidth) return _FrameColor;
                if(x > width -_FrameWidth || y > height -_FrameWidth) return _FrameColor;

                //draw rgb color
                if(x < _FrameWidth + RGBWidth)
                {
                    x = (x - _FrameWidth) / RGBWidth;
                    y = (y - _FrameWidth) / targetHeight; 
                    return tex2D(_MainTex,float2(x,y));
                }
                //draw Depth color
                else
                {
                    x = (x - _FrameWidth - RGBWidth) / depthWidth;
                    y = (y - _FrameWidth) / targetHeight;
                    
                    float depth = tex2D(_CameraDepthTexture, float2(x,y)).r;
                    depth = Linear01Depth(depth);

                    return depth;
                }
            }
            ENDCG
        }
    }
}
