#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor.Build;
using UnityEngine;
using UnityEditor;
using VRC.SDKBase;

namespace CottonUsagi
{
    [ExecuteInEditMode]
    public class FixUIFrameSize : MonoBehaviour, IEditorOnly
    {
        [SerializeField] private Transform CanvasBG;
        [SerializeField] private Transform FrameUpper;
        [SerializeField] private Transform FrameLowwer;

        private void Update()
        {
            if (CanvasBG == null) return;
            if (FrameUpper == null) return;
            if (FrameLowwer == null) return;

            if (transform.localScale.z != 1) transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y, 1);
            CanvasBG.localScale = new Vector3(1, 1, 1);
            FrameUpper.localScale = new Vector3(1, 1 / transform.localScale.y, 1);
            FrameLowwer.localScale = new Vector3(1, 1 / transform.localScale.y, 1);
        }


        /*
                [CustomEditor(typeof(FixUIFrameSize))]
                public class FixUIFrameSizeEditor : Editor
                {

                    void OnEnable()
                    {
                    }

                    public override void OnInspectorGUI()
                    {
                        FixUIFrameSize Target = target as FixUIFrameSize;

                        serializedObject.Update();


                        serializedObject.ApplyModifiedProperties();
                    }
                }
                */
    }
}
#endif
