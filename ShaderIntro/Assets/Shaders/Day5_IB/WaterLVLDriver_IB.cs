using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]

public class WaterLVLDriver_IB : MonoBehaviour
{
    [SerializeField]

    private Material m_material;

    [SerializeField]
    private MeshRenderer m_renderer;

    /* //if wanna assign multiple material
    private void Start()
    {
        if(m_material == null)
        {
            m_material = m_renderer.material;
        }
    }
    */

    void Update()
    {
        //Use Referance name chosen iin shader
        m_material.SetVector("Water_LVL_Origin", transform.position);
        m_material.SetVector("Water_LVL_Normal", transform.up);
    }
}

