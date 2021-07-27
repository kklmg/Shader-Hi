Shader "Unlit/PostProcessingBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("Blur Size", Range(0,0.1)) = 0.1
        [KeywordEnum(Low, Medium, High)] _Samples ("Sample amount", Float) = 0
        [Toggle(GAUSS)] _Gauss ("Gaussian Blur", float) = 0
        _StandardDeviation("Standard Deviation (Gauss only)", Range(0, 0.1)) = 0.02
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

            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
            #pragma shader_feature _Gauss

            #define PI 3.14159265359
            #define E 2.71828182846

            


            #if _SAMPLES_LOW
                #define SAMPLES 10
            #elif _SAMPLES_MEDIUM
                #define SAMPLES 30
            #else
                #define SAMPLES 100
            #endif

            #if GAUSS
                float sum = 0;
            #else
                float sum = SAMPLES;
            #endif

            
            

            float _BlurSize;

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
                #if GAUSS
                    //failsafe so we can use turn off the blur by setting the deviation to 0
                    if(_StandardDeviation == 0)
                    return tex2D(_MainTex, i.uv);
                #endif
                //init color variable
                float4 col = 0;
                #if GAUSS
                    float sum = 0;
                #else
                    float sum = SAMPLES;
                #endif

                //iterate over blur samples
                for(float index = 0; index < SAMPLES; index++)
                {
                    //get the offset of the sample
                    float offset = (index/(SAMPLES-1) - 0.5) * _BlurSize;
                    //get uv coordinate of sample
                    float2 uv = i.uv + float2(0, offset);
                    #if !GAUSS
                        //simply add the color if we don't have a gaussian blur (box)
                        col += tex2D(_MainTex, uv);
                    #else
                        //calculate the result of the gaussian function
                        float stDevSquared = _StandardDeviation*_StandardDeviation;
                        float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
                        //add result to sum
                        sum += gauss;
                        //multiply color with influence from gaussian function and add it to sum color
                        col += tex2D(_MainTex, uv) * gauss;
                    #endif
                }
                //divide the sum of values by the amount of samples
                col = col / sum;
                return col;
            }

            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
            #pragma shader_feature _Gauss

            #define PI 3.14159265359
            #define E 2.71828182846


            #if _SAMPLES_LOW
                #define SAMPLES 10
            #elif _SAMPLES_MEDIUM
                #define SAMPLES 30
            #else
                #define SAMPLES 100
            #endif

            #if GAUSS
                float sum = 0;
            #else
                float sum = SAMPLES;
            #endif

            float _BlurSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #if GAUSS
                    //failsafe so we can use turn off the blur by setting the deviation to 0
                    if(_StandardDeviation == 0)
                    return tex2D(_MainTex, i.uv);
                #endif
                //calculate aspect ratio
                float invAspect = _ScreenParams.y / _ScreenParams.x;
                //init color variable
                float4 col = 0;
                #if GAUSS
                    float sum = 0;
                #else
                    float sum = SAMPLES;
                #endif
                //iterate over blur samples
                for(float index = 0; index < SAMPLES; index++){
                    //get the offset of the sample
                    float offset = (index/(SAMPLES-1) - 0.5) * _BlurSize * invAspect;
                    //get uv coordinate of sample
                    float2 uv = i.uv + float2(offset, 0);
                    #if !GAUSS
                        //simply add the color if we don't have a gaussian blur (box)
                        col += tex2D(_MainTex, uv);
                    #else
                        //calculate the result of the gaussian function
                        float stDevSquared = _StandardDeviation*_StandardDeviation;
                        float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
                        //add result to sum
                        sum += gauss;
                        //multiply color with influence from gaussian function and add it to sum color
                        col += tex2D(_MainTex, uv) * gauss;
                    #endif
                }
                //divide the sum of values by the amount of samples
                col = col / sum;
                return col;
            }

            ENDCG
        }
    }


}