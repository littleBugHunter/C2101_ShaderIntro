using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AgentBasedPCGDungeon : MonoBehaviour
{
    public int DungeonWidth=20;
    public int DungeonHeight = 20;
    public Vector2Int targetEndPosition;
    public GameObject FloorTile;
    public GameObject BlockedTile;
    public GameObject RoomTile;
    public int AllowedEndDist;

    public int correctDirProbability = 70;
    public int minCorridorLength = 3;
    public int maxCorridorLength = 7;
    public RoomPlacement RP;
    public int maxWrongDirection = 2;




    List<Vector2Int> FloorTiles;

    List<Vector2Int> RoomPositionCandidates;


    public int numberOfAgents = 1;
    private void Start()
    {
        FloorTiles = new List<Vector2Int>();
        RoomPositionCandidates = new List<Vector2Int>();
        targetEndPosition = new Vector2Int(DungeonWidth, DungeonHeight);
        Instantiate(BlockedTile, new Vector3(targetEndPosition.x, 0, targetEndPosition.y), Quaternion.identity);

        for(int agentInd = 0; agentInd <numberOfAgents; agentInd++)
        {
            RunAgent();
        }
  
     

       RP.SetRoomData(RoomPositionCandidates.ToArray(), Vector2Int.zero, new Vector2Int(DungeonWidth, DungeonHeight));
       RP.placeRooms();

       AddRoomsToFloor(RP.Rooms.ToArray());

       GenerateBlockedTiles();

       DrawTiles();
    }

    public int GenerateBlockedTilesDistance = 3;
    public List<Vector2Int> BlockedTiles;
    void GenerateBlockedTiles()
    {
        int generateDistance = GenerateBlockedTilesDistance + maxCorridorLength;
      
           
                for (int x = -generateDistance+1; x < generateDistance + DungeonWidth; x++)
                {
               
                     for (int y = -generateDistance; y < generateDistance+DungeonHeight; y++)
                     {
                            Vector2Int p =  x * Vector2Int.right+y*Vector2Int.up;

                               if (!BlockedTiles.Contains(p)&&!FloorTiles.Contains(p))
                               {
                                    BlockedTiles.Add(p);
                               }
                     }
                }

                

        
    }


    void RunAgent()
    {
        Vector2Int pos = Vector2Int.zero;
        int wrongTurns = maxWrongDirection;


        Vector2Int lastDir = Vector2Int.zero;
        while ((targetEndPosition-pos).magnitude > AllowedEndDist)
        {
            //set direction
           
            int directionVar = Random.Range(0, 100);

            Vector2Int toEnd = targetEndPosition - pos;

            Vector2Int dir = Random.Range(0, 2) == 1 ? 
                toEnd.x>0?Vector2Int.right:Vector2Int.left 
                :toEnd.y > 0 ? Vector2Int.up : Vector2Int.down;
            

            if (directionVar > correctDirProbability&&wrongTurns>0&&lastDir != Vector2Int.zero)
            {
                wrongTurns--;
                dir *= -1;
            }
            int distance = Random.Range(minCorridorLength, maxCorridorLength + 1);
            if ( dir != -lastDir)
            {
              
           

            lastDir = dir;
            for (int step = 0; step < distance; step++)
            {
                pos = pos + dir;
                    if (pos.x > targetEndPosition.x)
                    {
                        dir = Vector2Int.up;
                    }
                    if (pos.y > targetEndPosition.y)
                    {
                        dir = Vector2Int.right;
                    }

                    if (!FloorTiles.Contains(pos))
                     {
                    FloorTiles.Add(pos);
                    

                     }
                    if (!FloorTiles.Contains(pos + Vector2Int.up))
                    {
                        FloorTiles.Add(pos + Vector2Int.up);
                    }
                    if (!FloorTiles.Contains(pos + Vector2Int.right))
                    {
                        FloorTiles.Add(pos + Vector2Int.right);
                    }
                    if (!FloorTiles.Contains(pos + Vector2Int.right + Vector2Int.up))
                    {
                        FloorTiles.Add(pos + Vector2Int.up + Vector2Int.right);
                    }



                    if ( step == distance-1 && !RoomPositionCandidates.Contains(pos))
                    {
                        RoomPositionCandidates.Add(pos);

                       
                    }

            }
            }





            //Move in direction and add CorridorTiles




        }



    }

    public void AddRoomsToFloor(Room[] rooms)
    {
        foreach (Room r in rooms)
        {
            Vector2Int bottomLeft = r.Center - ((r.Width / 2) * Vector2Int.right) - ((r.Height / 2) * Vector2Int.up);
            for (int x = 0; x < r.Width; x++)
            {
                for (int y = 0; y < r.Height; y++)
                {
                    Vector2Int pos = new Vector2Int(bottomLeft.x + x, bottomLeft.y + y);
                  
                    if (!FloorTiles.Contains(pos))
                    {
                        FloorTiles.Add(pos);


                    }
                   // Instantiate(RoomTile, pos, Quaternion.identity);

                }
            }

        }

    }


    void DrawTiles()
    {
        foreach(Vector2Int pos in FloorTiles)
        {
            Instantiate(FloorTile, new Vector3(pos.x, 0, pos.y), Quaternion.identity);

          
        }
        foreach (Vector2Int pos in BlockedTiles)
        {
            Instantiate(BlockedTile, new Vector3(pos.x, .5f, pos.y), Quaternion.identity);
        }
    }




}
