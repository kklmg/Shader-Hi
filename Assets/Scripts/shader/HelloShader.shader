Shader "Custom/HelloShader"
{
    properties
    {
        _Color ("Main Color", Color) = (1,1,1,0)
        _SpecColor ("Specular", Color) = (1,1,1,1)
        _Emission ("Emission", Color) = (0,0,0,0)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
        _MainTex("Basic Texture",2D)="White"{}
    }
    subshader
    {
        pass
        {
            Material
            {
                Diffuse [_Color]
                Ambient [_Color]
                Shininess [_Shininess]
                Specular [_SpecColor]
                Emission [_Emission]
            }
           
            
            lighting on 
            
             
            SetTexture[_MainTex]{ Combine texture * primary DOUBLE, texture * primary}
            
            setTexture[_MainTex]{ combine texture }
        }
    }
    Fallback"diffuse"
}
