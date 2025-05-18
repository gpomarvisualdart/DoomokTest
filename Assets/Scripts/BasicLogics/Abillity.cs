using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Abillity : MonoBehaviour
{
    [SerializeField] protected float power;

    public abstract void Execute();

    public abstract void AnimEvents(int index);

    public abstract void AttackEnds();
}
