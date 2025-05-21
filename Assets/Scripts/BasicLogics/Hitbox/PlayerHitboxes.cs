using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHitboxes : MonoBehaviour, IHitboxController
{
    Collider trigger;
    LogicPlayer plr;
    float currentDamage;
    float currentKnockBackPower;
    LayerMask hurtBoxes;


    private void OnEnable()
    {
        Transform current = transform;
        while (current != null)
        {
            plr = current.TryGetComponent(out LogicPlayer lb) ? lb : null;
            if (plr != null) { Debug.Log("Found player logic!"); break; }
            current = current.parent;
        }

        if (plr == null) { Debug.LogError("LogicBoss not found!"); return; }
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
        if (other.transform.parent.transform == plr.GetPlayerTransform()) return;
        Debug.Log(other.transform.parent.name);
        IDamageDealer dealDamage = other.transform.parent.TryGetComponent(out IDamageDealer dd) ? dd : null;
        if (dealDamage == null) return;
        var vect3_dir = other.transform.position - plr.GetPlayerTransform().position;
        dealDamage.DealDamage(currentDamage, vect3_dir, currentKnockBackPower);
    }
}
