using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class CameraPostProcessing : MonoBehaviour
{
    // Start is called before the first frame update
    private Camera _camera;

    [SerializeField]
    private Material postprocessMaterial;

    void Awake()
    {
        _camera = GetComponent<Camera>();
    }
    void Start()
    {
        _camera.depthTextureMode = _camera.depthTextureMode | DepthTextureMode.Depth;
        Debug.Log("abcd");
    }

    // Update is called once per frame
    void Update()
    {

    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postprocessMaterial)
        {
            //draws the pixels from the source texture to the destination texture
            Graphics.Blit(src, dest, postprocessMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
