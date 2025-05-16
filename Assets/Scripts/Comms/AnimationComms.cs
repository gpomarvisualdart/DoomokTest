using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationComms : MonoBehaviour, IAnimationEventSender
{
    public event EventHandler<IAnimationEventSender.PlayAnimationEventArgs> PlayAnimation;


    public void RequestPlayAnimation(int animIndex, bool isLock, bool canPass)
    {
        PlayAnimation?.Invoke(this, new IAnimationEventSender.PlayAnimationEventArgs { animIndex = animIndex, isLock = isLock, canPass = canPass});
    }
}
