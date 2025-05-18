using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenericAnimationEvents : MonoBehaviour
{
    AnimationComms animComms;

    void OnEnable()
    {
        if (animComms == null)
        {
            animComms = transform.parent.GetComponentInChildren<AnimationComms>();
            if (animComms == null) { Debug.LogError("No anim comms!"); return; }
        }
    }

    public void OnAnimationEndEvent(int animType)
    {
        if (animComms == null) { Debug.LogError("No anim comms!"); return; }
        animComms.OnAnimationEnds((int)AnimationTypes.Attack);
    }


    public void OnAnimationEventTrigger(string parse)
    {
        //Animation parse first element is animType and second is the index and seperated by a ':'
        var splitParse = parse.Split(":");
        if (splitParse.Length > 2 || splitParse.Length < 2) { Debug.LogError($"Parse length is not valid! Has to be 2 instead of {splitParse.Length}!"); return; }
        int animType;
        int eventIndex;
        if (!int.TryParse(splitParse[0], out animType)) return;
        if (!int.TryParse(splitParse[1], out eventIndex)) return;
        //Debug.Log($"This event is for {(AnimationTypes)animType} with event index of {eventIndex}!");
        animComms.OnAnimationEventTrigger(animType, eventIndex);
    }
}
