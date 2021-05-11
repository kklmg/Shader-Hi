Shader "Custom/PlantShader"
{
    Properties
    {
        _Color ("Main Color", Color) = (.5,.5,.5,.5)
        _MainTex("Main Texture",2D) = "white"{}
        _CutOff("alpha",Range(0,.9)) = .5
    }
    SubShader
    {
        material
        {
            Diffuse[_Color]
            Ambient[_Color]
        }

        lighting On

       
        cull off
        

        pass
        {
            alphatest greater[_CutOff]
            
            settexture[_MainTex]
            {
                Combine Texture * primary , Texture
            }
        }

        pass
        {
            ZWrite off
            
            ZTest Less
            
            AlphaTest LEqual [_CutOff]
            
            Blend SrcAlpha OneMinusSrcAlpha
            
            settexture[_MainTex]
            {
                Combine Texture * primary , Texture
            }
        }

    }
    FallBack "Diffuse"
}
