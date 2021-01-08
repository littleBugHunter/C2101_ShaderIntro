using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class WaterShaderDriver : MonoBehaviour
{
    [SerializeField]
    private Material material;

    // Update is called once per frame
    void Update()
    {
        material.SetVector("WaterLevelOrigin", transform.position);
        material.SetVector("WaterLevelNormal", transform.up);
    }
}
