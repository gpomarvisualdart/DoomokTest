using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenericAnimationEvents : MonoBehaviour, IAnimationAttackEvents
{
    public void AttackEvent()
    {
        Debug.Log("Fired!");
    }
}
