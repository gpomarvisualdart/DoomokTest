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
            Animator.StringToHash("Idle"),
            Animator.StringToHash("WalkFWD"),
            Animator.StringToHash("WalkBCK"),
            Animator.StringToHash("Dash"),
            Animator.StringToHash("Jump"),
            Animator.StringToHash("Falling"),
            Animator.StringToHash("Land"),
            Animator.StringToHash("Attack1Start"),
            Animator.StringToHash("Attack1End"),
            Animator.StringToHash("Attack2Start"),
            Animator.StringToHash("Attack2End"),
            Animator.StringToHash("Attack3Start"),
            Animator.StringToHash("Attack3End"),
            Animator.StringToHash("AttackAir"),
            1000
        }
    };
}
