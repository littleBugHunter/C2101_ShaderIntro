using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FlaskDriver : MonoBehaviour
{
    [SerializeField]
    private Material m_material;

   

    // Update is called once per frame
    void Update()
    {
        m_material.SetVector("WaterLevelOrigin", transform.position);
        m_material.SetVector("WaterLevelNormal", transform.up);
    }
}
