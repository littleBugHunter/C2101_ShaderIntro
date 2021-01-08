using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class WaterShaderDriver : MonoBehaviour
{
    [SerializeField]
    private Material m_material;
    [SerializeField]
    private MeshRenderer m_renderer;

    private void Start()
    {
        if (m_material == null)
        {
            if (Application.isPlaying)
            {
                m_material = m_renderer.material;
            }
        }
    }

    void Update()
    {
        m_material.SetVector("WaterLevelOrigin", transform.position);
        m_material.SetVector("WaterLevelNormal", transform.up);
    }
}
