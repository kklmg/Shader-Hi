using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveEnviorment : MonoBehaviour
{
    public Vector3 dissolveStartPoint;
    [Range(0, 1)]
    public float dissolveThreshold = 0;
    [Range(0, 1)]
    public float distanceEffect = 0.6f;

    void Start()
    {
        MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
        float maxDistance = 0;
        for (int i = 0; i < meshFilters.Length; i++)
        {
            float distance = CalculateMaxDistance(meshFilters[i].mesh.vertices);
            maxDistance = Mathf.Max(maxDistance, distance);
        }

        //Pass Shader variables
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetVector("_StartPoint", dissolveStartPoint);
            meshRenderers[i].material.SetFloat("_MaxDistance", maxDistance);
        }
    }

    void Update()
    {
        //pass variables to shader
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetFloat("_Threshold", dissolveThreshold);
            meshRenderers[i].material.SetFloat("_DistanceEffect", distanceEffect);
        }
    }

    float CalculateMaxDistance(Vector3[] vertices)
    {
        float maxDistance = 0;
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vert = vertices[i];
            float distance = (vert - dissolveStartPoint).magnitude;
            maxDistance = Mathf.Max(maxDistance, distance);
        }
        return maxDistance;
    }
}
