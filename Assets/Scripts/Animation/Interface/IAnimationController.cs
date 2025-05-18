using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAnimationController
{
    public void InitializeAnimation(int animIndex, bool isLock, Animator animator);

    public void ChangeAnimations(int animIndex, int animHashIndex, bool isLock, bool canPass, Animator animator);

    public void EndAnimation(string dataParse);
}
