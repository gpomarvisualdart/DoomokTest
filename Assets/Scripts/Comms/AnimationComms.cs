using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationComms : MonoBehaviour, IAnimationEventSender
{
    public event EventHandler<IAnimationEventSender.PlayAnimationEventArgs> PlayAnimation;
    public event EventHandler<IAnimationEventSender.AnimationEndsEventArgs> AnimationEndsEvent;
    public event EventHandler<IAnimationEventSender.AnimationEventTriggerArgs> AnimationTriggerEvent;


    public void RequestPlayAnimation(int animIndex, int animHashIndex, bool isLock, bool canPass)
    {
        PlayAnimation?.Invoke(this, new IAnimationEventSender.PlayAnimationEventArgs { animIndex = animIndex, animHashIndex = animHashIndex, isLock = isLock, canPass = canPass });
    }


    public void OnAnimationEnds(int animType)
    {
        AnimationEndsEvent?.Invoke(this, new IAnimationEventSender.AnimationEndsEventArgs { animType = animType });
    }


    public void OnAnimationEventTrigger(int animType, int index)
    {
        AnimationTriggerEvent?.Invoke(this, new IAnimationEventSender.AnimationEventTriggerArgs { animtype = animType, index = index });
    }
}
