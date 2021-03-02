using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoomPlacement :MonoBehaviour
{

    public int numberRooms = 5;
    public int minRoomWallSize = 3;
    public int maxRoomWallSize = 6;
    public int minDistFromStart = 5;
    public int minDistFromEnd = 5;
    public int startroomSize = 4;
    public int endroomSize = 5;




    public List<Vector2Int> PositionCandidates;
    public List<Room> Rooms;
    public Vector2Int StartPos;

    public Vector2Int EndPos;
    public void SetRoomData(Vector2Int[] posCandidates, Vector2Int startPos, Vector2Int endPos)
    {
        StartPos = startPos;
        EndPos = endPos;
        PositionCandidates = new List<Vector2Int>();

        foreach(Vector2Int pos in posCandidates)
        {
            if ( (startPos-pos).magnitude >= minDistFromStart && (endPos - pos).magnitude >= minDistFromEnd) {
                PositionCandidates.Add(pos);
            }


        }



    }


    public void placeRooms()
    {

        if ( PositionCandidates.Count< numberRooms)
        {
            Debug.LogError("Not Enough possible positions to place all rooms, try adjusting the PCGDungeon Settings");
            return;
        }

        Rooms = new List<Room>();

        for (int roomsPlaced = 0; roomsPlaced<numberRooms; roomsPlaced++)
        {

            Vector2Int pickedPosition = Vector2Int.zero;
            if (roomsPlaced == 0)
            {
                
                pickedPosition = PositionCandidates[Random.Range(0, PositionCandidates.Count)];
               
            }
            else
            {
                float maxDist = 0;
               
                for (int posCandidateIndex = 0; posCandidateIndex < PositionCandidates.Count; posCandidateIndex++)
                {
                    Vector2Int consideringPosition = PositionCandidates[posCandidateIndex];
                    float SmallestDistanceToAnyOtherRoom = float.PositiveInfinity;
                    foreach(Room r in Rooms)
                    {
                        float thisDist = (r.Center - consideringPosition).magnitude;

                        if (thisDist < SmallestDistanceToAnyOtherRoom)
                        {
                            SmallestDistanceToAnyOtherRoom = thisDist;
                        }
                    }
                    if(SmallestDistanceToAnyOtherRoom > maxDist)
                    {
                        maxDist = SmallestDistanceToAnyOtherRoom;
                        pickedPosition = consideringPosition;
                    }

                }
              
            }
            if (pickedPosition != Vector2Int.zero)
            {
                PositionCandidates.Remove(pickedPosition);
                Rooms.Add(PlaceRoom(pickedPosition));
            }
            else
            {
                Debug.LogError("Something went wrong placing this room");

            }
           
        }


        Rooms.Add(PlaceRoom(StartPos, startroomSize, startroomSize));
        Rooms.Add(PlaceRoom(EndPos, endroomSize, endroomSize));


    }
    public Room PlaceRoom(Vector2Int pos)
    {
        return new Room(pos,Random.Range(minRoomWallSize,maxRoomWallSize+1), Random.Range(minRoomWallSize, maxRoomWallSize + 1));
    }

    public Room PlaceRoom(Vector2Int pos,int Width, int Height)
    {
        return new Room(pos, Width, Height);
    }

}
