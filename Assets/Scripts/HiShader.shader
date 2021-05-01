Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTex ("Basic Texture", 2D) = "white" {}
        _BlendTex ("Blend Texture ", 2D) = "white" {}
    }
    SubShader
    {
       pass
        {
          
            SetTexture [_MainTex] {	combine texture }
			
            SetTexture [_BlendTex] {combine texture * previous}
        }
    }
    FallBack "Diffuse"
}
