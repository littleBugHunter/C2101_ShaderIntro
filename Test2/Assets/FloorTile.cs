using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorTile : MonoBehaviour
{
    public Vector4 UpDownLeftRight;
    public Vector4 TL_TR_BR_BL;
    public Renderer rend;

    private void Start()
    {
        Invoke("SetMaterialProperties",1);
    }
    public void SetMaterialProperties()
    {
        rend.material.SetVector("WallVec", UpDownLeftRight);

        rend.material.SetVector("CornerVec", TL_TR_BR_BL);
    }
}
