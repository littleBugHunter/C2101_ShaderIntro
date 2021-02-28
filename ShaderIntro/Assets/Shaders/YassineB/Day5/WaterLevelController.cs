using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class WaterLevelController : MonoBehaviour
{
    public Material material;

    public void Update()
    {
        material.SetVector("WaterLevelOrigin", transform.position);
        material.SetVector("WaterLevelNormal", transform.up);
    }
}
