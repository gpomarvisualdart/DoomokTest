using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenericHitboxes : MonoBehaviour, IHitboxController
{
    Collider trigger;
    LogicBoss boss;
    float currentDamage;
    float currentKnockBackPower;
    LayerMask hurtBoxes;


    private void OnEnable()
    {
        Transform current = transform;
        while (current != null)
        {
            boss = current.TryGetComponent(out LogicBoss lb) ? lb : null;
            if (boss != null) { Debug.Log("Found boss logic!"); break; }
            current = current.parent;
        }

        if (boss == null) { Debug.LogError("LogicBoss not found!"); return; }
        trigger = TryGetComponent(out Collider c) ? c : null;
        trigger.enabled = false;
    }


    public void HitboxActivation(bool turnOn, float damage, float knckBackPwr)
    {
        trigger.enabled = turnOn;
        currentDamage = damage;
        currentKnockBackPower = knckBackPwr;
    }


    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.parent.transform == boss.GetBossTransform()) return;
        Debug.Log(other.transform.parent.name);
        IDamageDealer dealDamage = other.transform.parent.TryGetComponent(out IDamageDealer dd) ? dd : null;
        if (dealDamage == null) return;
        var vect3_dir = other.transform.position - boss.GetBossTransform().position;
        dealDamage.DealDamage(currentDamage, vect3_dir, currentKnockBackPower);
    }
}
