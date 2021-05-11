Shader "Custom/2-3"
{
     Properties 
	{
        _IlluminCol ("illumin", Color) = (1,1,1,1)
        _Color ("Main Color", Color) = (1,1,1,0)
        _SpecColor ("High Light Color", Color) = (1,1,1,1)
        _Emission ("Emission", Color) = (0,0,0,0)
        _Shininess ("Shiness", Range (0.01, 1)) = 0.7
        _MainTex ("basic textyre", 2D) = "white" { }
    }
 
	
    SubShader 
	{
        Pass 
		{
			Material 
			{
                Diffuse [_Color]
                Ambient [_Color]
                Shininess [_Shininess]
                Specular [_SpecColor]
                Emission [_Emission]
            }

            Lighting On
	
            SeparateSpecular On

            SetTexture [_MainTex] 
			{
				
                constantColor [_IlluminCol]
			
                combine constant lerp(texture) previous
            }

            SetTexture [_MainTex] {  combine previous * texture   }

			SetTexture [_MainTex] 	{  Combine previous * primary DOUBLE, previous * primary}
        }
 
    }

}
