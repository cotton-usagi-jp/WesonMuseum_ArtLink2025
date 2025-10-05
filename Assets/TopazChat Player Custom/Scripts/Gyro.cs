
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class Gyro : UdonSharpBehaviour
{

    void Start()
    {
        
    }

    void LateUpdate()
    {
        transform.rotation = Quaternion.Euler(0, transform.parent.eulerAngles.y, 0);
    }
}
