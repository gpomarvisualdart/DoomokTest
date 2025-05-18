using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAnimationEventSender
{
    public event EventHandler<PlayAnimationEventArgs> PlayAnimation;
    public class PlayAnimationEventArgs : EventArgs { public int animIndex; public int animHashIndex; public bool isLock; public bool canPass; }

    public event EventHandler<AnimationEndsEventArgs> AnimationEndsEvent;
    public class AnimationEndsEventArgs : EventArgs { public int animType; }


    public event EventHandler<AnimationEventTriggerArgs> AnimationTriggerEvent;
    public class AnimationEventTriggerArgs : EventArgs { public int animtype; public int index;}
}
