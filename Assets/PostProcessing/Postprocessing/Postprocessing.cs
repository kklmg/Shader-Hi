using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Postprocessing : MonoBehaviour
{
    [SerializeField] private Material postprocessMaterial;

    //method which is automatically called by unity after the camera is done rendering
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //draws the pixels from the source texture to the destination texture
        Graphics.Blit(source, destination, postprocessMaterial);
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
