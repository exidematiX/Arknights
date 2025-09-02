using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float speed = 3;
    public float zoomSpped = 300;

    // Update is called once per frame
    void Update()
    {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");

        float scroll =  Input.GetAxisRaw("Mouse ScrollWheel");

        transform.Translate(new Vector3(horizontal*speed, -scroll* zoomSpped, vertical*speed) *Time.deltaTime ,Space.World);


    }
}
