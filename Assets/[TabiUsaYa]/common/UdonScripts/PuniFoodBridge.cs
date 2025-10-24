
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class PuniFoodBridge : UdonSharpBehaviour
{
    [SerializeField]
    private UdonBehaviour ReceiverBehavior;

    public override void OnPickup()
    {
        ReceiverBehavior.SendCustomEvent("OnTake");
    }

    public override void OnPickupUseDown()
    {
        ReceiverBehavior.SendCustomEvent("OnEat");
    }

    public override void OnDrop()
    {
        ReceiverBehavior.SendCustomEvent("OnRelease");
    }

    public void OnFinishAnimation()
    {
        ReceiverBehavior.SendCustomEvent("OnReleaseRock");
    }

}
