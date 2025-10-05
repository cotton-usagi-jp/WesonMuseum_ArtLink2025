
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using VRC.Economy;

namespace CottonUsagi.CustomEdit
{
    public class GroupButton : UdonSharpBehaviour
    {
        public string GroupId;

        public override void Interact()
        {
            if (string.IsNullOrEmpty(GroupId))
            {
                Debug.LogError("グループIDが空なので実行できません");
                return;
            }
            Store.OpenGroupPage(GroupId);
        }
    }

}
