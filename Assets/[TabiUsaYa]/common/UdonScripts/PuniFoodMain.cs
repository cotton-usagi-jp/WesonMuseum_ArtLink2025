
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

//Manualに固定する
[UdonBehaviourSyncMode(BehaviourSyncMode.Manual)]
public class PuniFoodMain : UdonSharpBehaviour
{
    [SerializeField]
    private int InitStepCount = 3;
    [SerializeField]
    private Animator SelfAnimator = null;
    [SerializeField]
    private Transform SelfTransform = null;
    [SerializeField]
    private AudioSource EatSound = null;
    [SerializeField]
    private bool AutoReset = true;

    private bool SequenceRock = false;
    private int LastStepCount;

    [UdonSynced(UdonSyncMode.None)] private int StepCount;


    private void Start()
    {
        StepCount = InitStepCount;
        LastStepCount = -1;
        SequenceRock = false;
    }

    public void OnTake()
    {
        //オーナ権限を委譲
        if (!Networking.IsOwner(this.gameObject))
            Networking.SetOwner(Networking.LocalPlayer, this.gameObject);

        SequenceRock = false;
    }

    public void OnEat()
    {
        if (SequenceRock) return;
        SequenceRock = true;

        StepCount--;
        if (StepCount < 0) StepCount = InitStepCount;

        RequestSerialization();
        SomeUpdate();
    }

    public void OnRelease()
    {
        if (StepCount > 0) return;
        if (!AutoReset) return;
        Reset();
    }

    public void OnReleaseRock()
    {
        SequenceRock = false;
    }

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

    private void SomeUpdate()
    {
        if (LastStepCount != StepCount)
        {
            if (SelfAnimator != null) SelfAnimator.SetInteger("Count", StepCount);

            if (LastStepCount != -1)
            {
                if (EatSound != null) EatSound.Play();
            }

            LastStepCount = StepCount;
        }

        return;
    }

    private void Reset()
    {
        if(SelfTransform != null)
        {
            SelfTransform.localPosition = Vector3.zero;
            SelfTransform.localRotation = Quaternion.Euler(Vector3.zero);
        }

        StepCount = InitStepCount;

        RequestSerialization();
        SomeUpdate();
    }
}

