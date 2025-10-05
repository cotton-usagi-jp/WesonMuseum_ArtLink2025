
using UdonSharp;
using UnityEngine;
using UnityEngine.UI;
using VRC.SDK3.Video.Components.Base;
using VRC.SDKBase;
using VRC.Udon;

public class TopazChatPlayerSharp : UdonSharpBehaviour
{
    [SerializeField]
    private VRCUrl StreamURL_Windows;
    [SerializeField]
    private VRCUrl StreamURL_Android;
    [SerializeField]
    private VRCUrl StreamURL_iOS;
    [SerializeField, Space]
    private BaseVRCVideoPlayer VideoPlayer;
    [SerializeField]
    private Animator Animator;
    [SerializeField, Space]
    private Slider SoundVolume;
    [SerializeField]
    private AudioSource SpeakerLeft;
    [SerializeField]
    private AudioSource SpeakerRight;

    private int _resyncParameterHash;
    private int _videoStartParameterHash;


    void Start()
    {
        _resyncParameterHash = Animator.StringToHash("Resync");
        _videoStartParameterHash = Animator.StringToHash("VideoStart");
        Resync();
        OnSoundVolume();
    }

    public override void OnVideoStart()
    {
        Animator.SetTrigger(_videoStartParameterHash);
    }

    public void Resync()
    {
        Animator.ResetTrigger(_videoStartParameterHash);
        Animator.SetTrigger(_resyncParameterHash);
    }

    public void GlobalSync()
    {
        SendCustomNetworkEvent(VRC.Udon.Common.Interfaces.NetworkEventTarget.All, "Resync");
        Resync();
    }

    public void Play()
    {
#if UNITY_STANDALONE_WIN
        VideoPlayer.PlayURL(StreamURL_Windows);
#elif UNITY_ANDROID
        VideoPlayer.PlayURL(StreamURL_Android);
#elif UNITY_IOS
        VideoPlayer.PlayURL(StreamURL_iOS);
#else
        VideoPlayer.PlayURL(StreamURL_Windows);
#endif
    }

    public void Stop()
    {
        VideoPlayer.Stop();
    }

    public void OnSoundVolume()
    {
        if (SoundVolume == null) return;

        SpeakerLeft.volume = SoundVolume.value;
        SpeakerRight.volume = SoundVolume.value;
    }

}

