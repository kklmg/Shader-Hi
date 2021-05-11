Shader "Custom/light_AlphaTest"
{
    Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,0)
        _SpecColor ("High Light Color", Color) = (1,1,1,1)
        _Emission ("Emission", Color) = (0,0,0,0)
        _Shininess ("Shiness", Range (0.01, 1)) = 0.7
        _MainTex ("basic textyre", 2D) = "white" { }
		_cutOff("alpha",Range(0,1)) = 0.5
    }
 
	
    SubShader 
	{
        Pass 
		{
			alphatest greater [_cutOff]
			
			Material 
			{
                Diffuse [_Color]
                Ambient [_Color]
                Shininess [_Shininess]
                Specular [_SpecColor]
                Emission [_Emission]
            }

            Lighting On

			SetTexture [_MainTex] { combine texture * primary }
        }
 
    }
}
