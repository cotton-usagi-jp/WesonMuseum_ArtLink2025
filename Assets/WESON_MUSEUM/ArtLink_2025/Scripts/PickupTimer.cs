
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class PickupTimer : UdonSharpBehaviour
{
    [SerializeField]
    private float LimitTimer = 10f;
    [SerializeField]
    private Animator SelfAnimator = null;


    /// <summary>
    /// (PuniFoodPickup) 掴み中
    /// </summary>
    [UdonSynced(UdonSyncMode.None)] protected bool IsGrab;
    /// <summary>
    /// (PuniFoodPickup) 移動済み
    /// </summary>
    [UdonSynced(UdonSyncMode.None)] protected bool IsMoved;
    /// <summary>
    /// (PuniFoodPickup) タイマー
    /// </summary>
    [UdonSynced(UdonSyncMode.None)] protected float ResetTimer;
    /// <summary>
    /// (PuniFoodPickup) 開いているか
    /// </summary>
    [UdonSynced(UdonSyncMode.None)] protected bool IsOpened;

    private bool LastIsOpened;

    // core event ########################################

    public void Start()
    {
        IsGrab = false;
        IsMoved = false;
        ResetTimer = -1f;
        LastIsOpened = IsOpened = false;
    }

    /// <summary>
    /// [BridgeEvent]持ち上げた
    /// </summary>
    public override void OnPickup()
    {
        if (!Networking.IsOwner(this.gameObject))
            Networking.SetOwner(Networking.LocalPlayer, this.gameObject);

        IsGrab = true;
        IsMoved = true;
        ResetTimer = LimitTimer;
        RequestSerialization();
    }

    /// <summary>
    /// [BridgeEvent]使った
    /// </summary>
    public override void OnPickupUseDown()
    {
        if(SelfAnimator != null)
        {
            IsOpened = !IsOpened;
            RequestSerialization();
            SomeUpdate();
        }
    }

    /// <summary>
    /// [BridgeEvent]放した
    /// </summary>
    public override void OnDrop()
    {
        IsGrab = false;
        RequestSerialization();
    }

    public void Update()
    {
        if (IsGrab) return;
        if (ResetTimer < 0) return;

        ResetTimer -= Time.deltaTime;
        if (ResetTimer < 0) Reset();
    }

    // sync function ########################################

    public override void OnPreSerialization()
    {

    }

    public override void OnDeserialization()
    {
        SomeUpdate();
    }

    public override void OnPlayerJoined(VRCPlayerApi player)
    {
        RequestSerialization();

        SomeUpdate();
    }

    // core function ########################################

    public void Reset()
    {
        IsMoved = false;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.Euler(Vector3.zero);
        ResetTimer = -1f;

        if (SelfAnimator != null)
        {
            IsOpened = false;
        }

        RequestSerialization();
        SomeUpdate();
    }

    private void SomeUpdate()
    {
        if((SelfAnimator != null) && (LastIsOpened != IsOpened))
        {
            SelfAnimator.SetBool("IsOpen", IsOpened);
            LastIsOpened = IsOpened;
        }

    }

}
