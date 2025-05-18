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

    [SerializeField] int defaultAnimHashArray;
    [SerializeField] int currentAnimHashArray;


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


    public void ChangeAnimations(int animIndex, int animHashIndex, bool isLock, bool canPass, Animator animator)
    {
        if (animator == null) return;
        if (animIndex == 1000)
        {
            animator.CrossFade(AnimationIndexes.GenericAnimations[0], 0f, 0);
            currentLockStatus = false;
            return;
        }
        if (currentLockStatus && !canPass) return;
        if (currentAnimIndex == animIndex) return;
        animator.CrossFade(AnimationIndexes.AnimationHashes[animHashIndex][animIndex], 0f, 0);
        currentLockStatus = isLock;
    }


    private void PlayAnimationReceiver(object sender, IAnimationEventSender.PlayAnimationEventArgs e)
    {
        ChangeAnimations(e.animIndex, e.animHashIndex, e.isLock, e.canPass, animator);
    }


    public void EndAnimation(string dataParse)
    {
        //Parse holds Animation type, AnimHashArray of choice to play from, is the animation locked, and whether it can bypass locked animations seperated with a ':'
        //1000 will account as no animation and will play idle animation instead

        int animIndex;
        int animHashArray;
        bool isLock;
        bool canBypass;

        var splitParse = dataParse.Split(":");
        if (splitParse.Length < 4 || splitParse.Length > 4) { Debug.LogError($"Data parse length is not valid! It needs to be 4 and not {splitParse.Length}!"); return; }

        if (!int.TryParse(splitParse[0], out animIndex)) return;
        if (!int.TryParse(splitParse[1], out animHashArray)) return;
        if (!bool.TryParse(splitParse[2], out isLock)) return;
        if (!bool.TryParse(splitParse[3], out canBypass)) return;


        ChangeAnimations(animIndex, animHashArray, isLock, canBypass, animator);
    }
}
