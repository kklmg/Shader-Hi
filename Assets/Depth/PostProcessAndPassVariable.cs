using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class PostProcessAndPassVariable : MonoBehaviour
{
    // Start is called before the first frame update
    private Camera _camera;
    private Matrix4x4 _lastVP;

    private Matrix4x4 CurrentVPMatrix
    {
        get { return Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix; }
    }

    [SerializeField]
    private Material postprocessMaterial;

    void Awake()
    {
        _camera = GetComponent<Camera>();
    }
    void Start()
    {
        _camera.depthTextureMode = _camera.depthTextureMode | DepthTextureMode.Depth;
        _lastVP = CurrentVPMatrix;
    }

    // Update is called once per frame
    void Update()
    {

    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postprocessMaterial)
        {
            PassFrustumDirection(postprocessMaterial);
            PassVPMatrix(postprocessMaterial);

            //draws the pixels from the source texture to the destination texture
            Graphics.Blit(src, dest, postprocessMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }


    }

    private void PassFrustumDirection(Material material)
    {
        if (material == null) return;

        Camera cam = Camera.main;

        //tan(fov/2)
        float tanHalfFOV = Mathf.Tan(0.5f * cam.fieldOfView * Mathf.Deg2Rad);

        float halfHeight = tanHalfFOV * cam.nearClipPlane;
        float halfWidth = halfHeight * cam.aspect;

        Vector3 toTop = cam.transform.up * halfHeight;
        Vector3 toRight = cam.transform.right * halfWidth;
        Vector3 forward = cam.transform.forward * cam.nearClipPlane;

        Vector3 toTopLeft = forward + toTop - toRight;
        Vector3 toBottomLeft = forward - toTop - toRight;
        Vector3 toTopRight = forward + toTop + toRight;
        Vector3 toBottomRight = forward - toTop + toRight;

        // toTopLeft / nearPlane = cameraToDest / depth
        // => cameraToDest = toTopLeft / nearPlane * depth  
        toTopLeft /= cam.nearClipPlane;
        toBottomLeft /= cam.nearClipPlane;
        toTopRight /= cam.nearClipPlane;
        toBottomRight /= cam.nearClipPlane;


        Matrix4x4 frustumDir = Matrix4x4.identity;
        frustumDir.SetRow(0, toBottomLeft);
        frustumDir.SetRow(1, toBottomRight);
        frustumDir.SetRow(2, toTopLeft);
        frustumDir.SetRow(3, toTopRight);
        material.SetMatrix("_FrustumDir", frustumDir);
    }

    private void PassVPMatrix(Material material)
    {
        if (material == null) return;

        Matrix4x4 currentVP = CurrentVPMatrix;
        Matrix4x4 currentInverseVP = CurrentVPMatrix.inverse;
        material.SetMatrix("_CurrentInverseVP", currentInverseVP);
        material.SetMatrix("_LastVP", _lastVP);
        
        _lastVP = currentVP;
    }
}
