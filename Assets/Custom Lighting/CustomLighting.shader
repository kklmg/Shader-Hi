Shader "Custom/CustomLighting"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HDR] _Emission ("Emission", color) = (0,0,0)

        _Ramp ("Toon Ramp", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf Custom fullforwardshadows
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        sampler2D _Ramp;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input i, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            //sample and tint albedo texture
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;

            // o.Emission = col;

        }

        float4 LightingCustom(SurfaceOutput s, float3 lightDir, float atten)
        {
            float towardsLight = dot(s.Normal, lightDir);

            //remap the value from -1 to 1 to between 0 and 1
            towardsLight = towardsLight * 0.5 + 0.5;

            //read from toon ramp
            float3 lightIntensity = tex2D(_Ramp, towardsLight).rgb;

            //combine the color
            float4 col;
            //intensity we calculated previously, diffuse color, light falloff and shadowcasting, color of the light
            col.rgb = lightIntensity * s.Albedo * atten * _LightColor0.rgb;
            //in case we want to make the shader transparent in the future - irrelevant right now
            col.a = s.Alpha; 

            return col;
        }


        ENDCG
    }
    FallBack "Diffuse"
}
