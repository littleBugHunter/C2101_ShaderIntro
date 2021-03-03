using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpringAmountHandle : MonoBehaviour
{
    
    public static int HandlePositionValue = Shader.PropertyToID("HandlePosition");

    public Material material;
    public Material material2;
    
    void Update()
    {
        material.SetVector(HandlePositionValue, this.transform.position);
        material2.SetVector(HandlePositionValue, this.transform.position);
    }
}
