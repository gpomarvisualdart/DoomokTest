using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenericAnimationController : MonoBehaviour, IAnimationController
{
    Animator animator;
    IAnimationEventSender animationComms;
    int[] currentHashArray;
    int currentAnimIndex;
    bool currentLockStatus;


    private void OnEnable()
    {
        animator = GetComponent<Animator>();
        currentLockStatus = false;
        if (animationComms == null)
        {
            animationComms = transform.parent.GetComponentInChildren<IAnimationEventSender>();
            if (animationComms == null) Debug.LogError("No anim comms!");
        }
        animationComms.PlayAnimation += PlayAnimationReceiver;
    }


    private void OnDisable()
    {
        animationComms.PlayAnimation -= PlayAnimationReceiver;
    }


    public void InitializeAnimation(int animIndex, bool isLock, Animator animator)
    {
        throw new System.NotImplementedException();
    }


    public void ChangeAnimations(int animIndex, bool isLock, bool canPass, Animator animator)
    {
        if (animator == null) return;
        if (animIndex == 100) { animator.CrossFade(AnimationIndexes.GenericAnimations[0], 0f, 0); return; }
        if (currentLockStatus && !canPass) return;
        if (currentAnimIndex == animIndex) return;
        animator.CrossFade(AnimationIndexes.GenericAnimations[animIndex], 0f, 0);
        currentLockStatus = isLock;
    }


    private void PlayAnimationReceiver(object sender, IAnimationEventSender.PlayAnimationEventArgs e)
    {
        ChangeAnimations(e.animIndex, e.isLock, e.canPass, animator);
    }


    public void testAnimEvent(string text)
    {
        Debug.Log(text);
    }
}
