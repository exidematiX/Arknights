using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using UnityEngine;

public class Waypoints : MonoBehaviour
{
    public static Waypoints Instance { get; private set; }

    private List<Transform> waypointList;

    private void Awake()
    {
        Instance = this;
        Init();
    }

    private void Init()
    {
        Transform[] transfroms = transform.GetComponentsInChildren<Transform>();
        waypointList = new List<Transform>(transfroms);
        waypointList.RemoveAt(0);
    }

    public int GetLength()
    {
        return waypointList.Count;
    }

    public Vector3 GetWaypoint(int index)
    {
        return waypointList[index].position;
    }
}
