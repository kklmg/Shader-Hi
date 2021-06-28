using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class MaterialController : MonoBehaviour
{
    private Material _material;
    private Texture _texture;

    private float _elapsedTime;

    [SerializeField] private float _updateInterval = 1f;

    [SerializeField][Range(0,1f)] private float _cellWidth = 0.25f;
    [SerializeField][Range(0, 1f)] private float _cellHeight = 0.25f;

    private void Awake()
    {
        var meshRenderer = GetComponent<MeshRenderer>();
        _material = meshRenderer.material;

        if (_material == null) Debug.Log("asdf");

        _material.mainTextureScale = new Vector2(_cellWidth, _cellHeight);
    }

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        _elapsedTime += Time.deltaTime;

        if (_elapsedTime > _updateInterval)
        {
            var offset = _material.mainTextureOffset;

            var offset_x = offset.x + _cellWidth - (int)(offset.x + _cellWidth);
        

            offset = new Vector2(offset_x, offset.y /*+ _cellHeight*/);

            _material.mainTextureOffset = offset;

            _elapsedTime = 0;
        }
    }
}
