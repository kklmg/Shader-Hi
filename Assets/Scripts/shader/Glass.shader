Shader "Custom/Glass"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,0)
        _SpecColor("High Color",Color) = (1,1,1,1)
        _Emission("Emission",Color) = (0,0,0,0)
        _Shininess("shininess",Range(0.01,1)) = 0.7
        _MainTex("Main Texture",2D)= "white"{}
    }
    SubShader
    {
        material
        {
            //Diffuse[_Color]
            //Ambient[_Color]
            //Shininess[_Shininess]
            //Specular[_SpecColor]
            //Emission[_Emission]
        }

        //lighting On

        separateSpecular on

        blend SrcAlpha OneMinusSrcAlpha


        pass
        {
            cull front
            
            settexture[_MainTex]
            {
                Combine primary * Texture
            }
        }

       

    }
    FallBack "Diffuse"
}
