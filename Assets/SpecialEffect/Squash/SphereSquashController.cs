using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SphereCollider))]
[RequireComponent(typeof(MeshRenderer))]
[ExecuteInEditMode]
public class SphereSquashController : MonoBehaviour
{
    // Start is called before the first frame update
    private Material _material;
    [SerializeField] private float _radius = 0.5f;

    void Awake()
    {
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        _material = meshRenderer.material;
    }

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        float topY = transform.position.y + _radius;
        float bottomY = transform.position.y - _radius;

        _material.SetFloat("_TopY", topY);
        _material.SetFloat("_BottomY", bottomY);
    }
}
