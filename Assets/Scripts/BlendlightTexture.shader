Shader "Custom/BlendlightTexture"
{
   
    Properties 
	{
        _IlluminCol ("diffuse", Color) = (1,1,1,1)
        _MainTex ("Basic texture", 2D) = "white" {}
    }
    
    SubShader 
	{
        Pass 
		{
		
            Material 
			{
                Diffuse (1,1,1,1)
                Ambient (1,1,1,1)
            }
 

            Lighting On
 

            SetTexture [_MainTex] 
			{

                constantColor [_IlluminCol]
			
                combine constant lerp(texture) previous
            }

            SetTexture [_MainTex] {combine previous * texture }
 
        }
    }
    FallBack "Diffuse"
}
