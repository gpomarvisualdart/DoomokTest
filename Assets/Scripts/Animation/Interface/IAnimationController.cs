using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAnimationController
{
    public void InitializeAnimation(int animIndex, bool isLock, Animator animator);

    public void ChangeAnimations(int animIndex, bool isLock, bool canPass, Animator animator);
}
