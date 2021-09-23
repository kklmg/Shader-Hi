Shader "Unlit/Fire"
{
    Properties
    {
        _MainTex ("Fire Noise", 2D) = "white" {}
        _ScrollSpeed("Animation Speed", Range(0, 2)) = 1
        
        _Color1 ("Color 1", Color) = (0, 0, 0, 1)
        _Color2 ("Color 2", Color) = (0, 0, 0, 1)
        _Color3 ("Color 3", Color) = (0, 0, 0, 1)
        
        _Edge1 ("Edge 1-2", Range(0, 1)) = 0.25
        _Edge2 ("Edge 2-3", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags{ "RenderType"="transparent" "Queue"="transparent"}
        LOD 100

        Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		//ZWrite Off

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

            //tint of the texture
			fixed4 _Color1;
			fixed4 _Color2;
			fixed4 _Color3;
			
			float _Edge1;
			float _Edge2;
			
			float _ScrollSpeed;

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
                //I square this here to make the fire look a bit more "full"
			    float fireGradient = 1 - i.uv.y;
			    fireGradient = fireGradient * fireGradient;

			    //calculate fire UVs and animate them
			    float2 fireUV = TRANSFORM_TEX(i.uv, _MainTex);
			    fireUV.y -= _Time.y * _ScrollSpeed;

			    //get the noise texture
			    float fireNoise = tex2D(_MainTex, fireUV).x;
			    
			    //calculate whether fire is visibe at all and which colors should be shown

                //float outline = step(fireNoise, fireGradient);
                //float edge1 = step(fireNoise, fireGradient - _Edge1);
                //float edge2 = step(fireNoise, fireGradient - _Edge2);

                float outline = AAStep(fireNoise, fireGradient);
                float edge1 = AAStep(fireNoise, fireGradient - _Edge1);
                float edge2 = AAStep(fireNoise, fireGradient - _Edge2);
			    
			    //define shape of fire
			    fixed4 col = _Color1 * outline;

			    //add other colors
			    col = lerp(col, _Color2, edge1);
			    col = lerp(col, _Color3, edge2);
			    
			    //uv to color
				return col;
            }
            ENDCG
        }
    }
}
