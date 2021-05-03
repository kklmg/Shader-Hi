Shader "Custom/AlphaTest"
{
    Properties
    {
        _MainTex("Main Texture",2D)= "white"{}
    }
    SubShader
    {
        pass
        {
           alphaTest greater 0.6
            
            settexture[_MainTex]
            {
                Combine primary * Texture
            }
        }

    }
    FallBack "Diffuse"
}
