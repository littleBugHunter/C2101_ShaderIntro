using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Room : ScriptableObject
{

    public Vector2Int Center;
    public int Width = 2;
    public int Height = 2;
    public float relativePos = .5f;


    public Room(Vector2Int center,int width,int height)
    {
        Center = center;
        Width = width;
        Height = height;
    }

}
