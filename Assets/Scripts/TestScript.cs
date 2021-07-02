using System.Collections;
using System.Collections.Generic;

using UnityEngine;

public class TestScript : MonoBehaviour
{
    public Vector3 from = new Vector3(1, 1, 1);
    public Vector3 to = new Vector3(1, 0, 1);

    public float angle;
    public float angle2;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void OnClickButton()
    {
        angle = Vector3.Angle(from, to);

        Debug.Log(angle);

        angle2 = Mathf.Acos(Mathf.Clamp(Vector3.Dot(from.normalized, to.normalized), -1f, 1f)) * 57.29578f;

        Debug.Log(angle2);
    }

    public void Magnitude(Vector3 vector3)
    {
        Mathf.Sqrt(vector3.x * vector3.x + vector3.y * vector3.y + vector3.z * vector3.z);
    }
}
