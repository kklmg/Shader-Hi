Shader "Unlit/DissolveDirection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _PlaneOffset("PlaneOffset",float) = 1
        _EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
		_RampTex("Ramp", 2D) = "white" {}

        _DissolveDirection("DissolveDirection",vector) = (1,1,1,0)
        _DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5
        _StartPoint("StartPoint",vector) = (1,1,1,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull off
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
                float2 uvMainTex : TEXCOORD0;
                float2 uvNoiseTex : TEXCOORD1;
                float2 uvRampTex : TEXCOORD2;
                float3 objPos : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Threshold;
            sampler2D _RampTex;
			float4 _RampTex_ST;

            float4 _StartPoint;
            float4 _DissolveDirection;
            float _PlaneOffset;
            float _DistanceEffect;

            float _EdgeLength;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.uvRampTex = TRANSFORM_TEX(v.uv, _RampTex);

                o.objPos = v.vertex;

                fixed4 dissolveDir = normalize(_DissolveDirection);

                return o;
            }

            float DistancePointToPlane(float3 p,vector plane)
            {

                return (plane.x*p.x +plane.y*p.y+plane.z*p.z + plane.w) 
                / sqrt(plane.x*plane.x + plane.y*plane.y + plane.z*plane.z);
            } 

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = DistancePointToPlane(i.objPos, _DissolveDirection);
                //float distNormal = DistancePointToPlane(i.objPos, _DissolveDirection)/1.712;

               	//fixed noise = tex2D(_NoiseTex, i.uvNoiseTex).r;
                //fixed cutout = lerp(noise,distNormal,_DistanceEffect) ;

                   
				clip(dist - _PlaneOffset);

                float degree = saturate((dist - _PlaneOffset) / _EdgeLength);
				fixed4 edgeColor = tex2D(_RampTex, float2(degree, degree));

				fixed4 col = tex2D(_MainTex, i.uvMainTex);

				fixed4 finalColor = lerp(edgeColor, col, degree);
				return fixed4(finalColor.rgb, 1);
            }
            ENDCG
        }
    }
}
