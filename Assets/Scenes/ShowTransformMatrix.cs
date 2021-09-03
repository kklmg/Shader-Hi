using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class ShowTransformMatrix : MonoBehaviour
{
    // Start is called before the first frame update

    public Matrix4x4 LocalToWorldMatrix;
    public Matrix4x4 WorldToLocalMatrix;

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        LocalToWorldMatrix = transform.localToWorldMatrix;
        WorldToLocalMatrix = transform.worldToLocalMatrix;
    }
}
