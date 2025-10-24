using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRC.SDKBase;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace CottonUsagi.FoodItems
{
    [ExecuteInEditMode]
    public class WorldColorChanger : MonoBehaviour, IEditorOnly
    {
        [SerializeField] public Color AmbientColor = Color.white;
        [SerializeField] public List<Material> MaterialsList;

        private void Start()
        {
            UpdateMaterials();
        }

        void OnValidate()
        {
            UpdateMaterials();
        }

        private void UpdateMaterials()
        {
            int propID = Shader.PropertyToID("_WorldColor");

            if (MaterialsList != null)
            {
                MaterialsList.ForEach(m =>
                {
                    m.SetColor(propID, AmbientColor);
                });
            }
        }

#if UNITY_EDITOR
        [CustomEditor(typeof(WorldColorChanger))]
        public class WorldColorChangerEditor : Editor
        {
            const string Message = "このプログラムはだんごの色、お茶の色をワールドの雰囲気に合わせるためのものです。\n色味を変更したい場合にご利用ください。\n\nこちらを操作すると、関連するマテリアル全てのWorld (Light) Colorを操作します。マテリアルは既に登録してあります。\n\nこのPrefabは残しておいてもVRChatにアップロードされないので、ヒエラルキーに置いていても大丈夫です。";

            Dictionary<string, SerializedProperty> property = new Dictionary<string, SerializedProperty>();
            private Vector2 _scrollPosition = Vector2.zero;
            private bool isListOpen;

            private void OnEnable()
            {
                property.Add(nameof(AmbientColor), serializedObject.FindProperty(nameof(AmbientColor)));
                property.Add(nameof(MaterialsList), serializedObject.FindProperty(nameof(MaterialsList)));
            }

            public override void OnInspectorGUI()
            {
                serializedObject.Update();

                var style = new GUIStyle(EditorStyles.textArea)
                {
                    wordWrap = true
                };

                GUIStyle boldtext = new GUIStyle(GUI.skin.label);
                boldtext.fontStyle = FontStyle.Bold;
                GUIStyle normaltext = new GUIStyle(GUI.skin.label);
                normaltext.fontStyle = FontStyle.Normal;

                EditorGUILayout.TextField(Message, style, GUILayout.Height(200f));

                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();

                property[nameof(AmbientColor)].colorValue = EditorGUILayout.ColorField("共通のワールド色", property[nameof(AmbientColor)].colorValue);

                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();

                if (GUILayout.Button("マテリアルを表示する"))
                {
                    isListOpen = !isListOpen;
                }

                if (isListOpen)
                {
                    EditorGUILayout.PropertyField(property[nameof(MaterialsList)], new GUIContent("適用するマテリアル"));
                }

                serializedObject.ApplyModifiedProperties();
            }
        }
#endif

    }
}
