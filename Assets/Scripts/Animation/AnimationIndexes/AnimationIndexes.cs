using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AnimationIndexes
{

    public readonly static int[][] AnimationHashes = new int[][]
    { new int[] //BossAnimations
        {
        Animator.StringToHash("Idle"),
        Animator.StringToHash("Attack 1"),
        Animator.StringToHash("Attack 2"),
        Animator.StringToHash("Attack 3"),
        Animator.StringToHash("AirAttack 1"),
        Animator.StringToHash("AirAttack 2"),
        Animator.StringToHash("AirAttack 3"),
        Animator.StringToHash("Skill 1"),
        Animator.StringToHash("Skill 2"),
        Animator.StringToHash("Skill 3"),
        Animator.StringToHash("WalkFWD"),
        Animator.StringToHash("WalkBCK"),
        Animator.StringToHash("Jump"),
        Animator.StringToHash("Land"),
        Animator.StringToHash("Death"),
        1000
        },

        new int[]  //GenericAnimations
        {
            Animator.StringToHash("Idle"), //0
            Animator.StringToHash("WalkFWD"), //1
            Animator.StringToHash("WalkBCK"), //2
            Animator.StringToHash("Dash"), //3
            Animator.StringToHash("Jump"), //4
            Animator.StringToHash("Falling"), //5
            Animator.StringToHash("Land"), //6
            Animator.StringToHash("Attack1Start"), //7
            Animator.StringToHash("Attack1End"), //8
            Animator.StringToHash("Attack2Start"), //9
            Animator.StringToHash("Attack2End"), //10
            Animator.StringToHash("Attack3Start"), //11
            Animator.StringToHash("Attack3End"), //12
            Animator.StringToHash("AttackAir"), //13
            1000 //14
        }
    };
}
