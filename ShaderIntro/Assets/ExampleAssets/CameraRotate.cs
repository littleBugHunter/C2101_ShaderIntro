using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotate : MonoBehaviour
{ public float speed = 1;
    // Start is called before the first frame update

    Vector3 startpos;
    void Start()
    {
        startpos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position =new Vector3( Mathf.Sin(Time.time * speed)*startpos.x,0, Mathf.Cos(Time.time * speed)* startpos.z);

        transform.LookAt(Vector3.zero);
    }
}
