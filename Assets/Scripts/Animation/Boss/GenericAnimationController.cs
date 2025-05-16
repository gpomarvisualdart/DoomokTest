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
        Debug.Log("not null");
        if (animIndex == 100) { animator.CrossFade(AnimationIndexes.GenericAnimations[0], 0.2f, 0); return; }
        Debug.Log("anim index not 0");
        Debug.Log(canPass);
        if (currentLockStatus == true && canPass == false) return;
        Debug.Log("can pass");
        if (currentAnimIndex == animIndex) return;
        Debug.Log("not same anim");
        animator.CrossFade(AnimationIndexes.GenericAnimations[animIndex], 0.2f, 0);
        currentLockStatus = isLock;
    }


    private void PlayAnimationReceiver(object sender, IAnimationEventSender.PlayAnimationEventArgs e)
    {
        ChangeAnimations(e.animIndex, e.isLock, e.canPass, animator);
    }
}
