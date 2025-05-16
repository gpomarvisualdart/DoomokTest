using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAnimationEventSender
{
    public event EventHandler<PlayAnimationEventArgs> PlayAnimation;
    public class PlayAnimationEventArgs : EventArgs { public int animIndex; public bool isLock; public bool canPass; }
}
