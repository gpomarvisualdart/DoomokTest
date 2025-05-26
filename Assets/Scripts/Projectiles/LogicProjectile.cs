using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ProjectilePoolObject;

public class LogicProjectile : MonoBehaviour
{
    Vector3 position;
    Vector3 dir;
    float spd;
    float dur;
    float damage;
    float knck;
    int collideLayers;
    CapsuleCollider trigger;
    Rigidbody rb;
    Transform caller;
    float durCount = 0f;
    GameObject visual;
    


    public void InitializeProjectile(ProjectileStat stat, ProjectileCapsuleColliderStat collider, GameObject prfb)
    {
        if (!transform.gameObject.activeInHierarchy) return;
        transform.position = stat.caller.position;
        caller = stat.caller;
        dir = stat.direction;
        spd = stat.speed;
        dur = stat.duration;
        damage = stat.damage;
        knck = stat.knockback;

        visual = Instantiate(prfb, transform);

        if (rb == null) rb = transform.TryGetComponent(out Rigidbody rg) ? rg : null;

    }


    private void FixedUpdate()
    {
        if (dir == Vector3.zero) return;

        if (durCount < dur)
        {
            durCount += Time.fixedDeltaTime;
            rb.velocity = dir * spd;
        }
        else 
        {
            durCount = 0f;
            gameObject.SetActive(false);
            Destroy(visual);

            if (transform.TryGetComponent(out CapsuleCollider cc) ? cc : null) { Destroy(cc); }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.parent.transform == caller.transform) return;

        Transform target = other.transform.parent.transform;
        IDamageDealer dd = target.TryGetComponent(out IDamageDealer deal) ? deal : null;
        if (dd == null) return;
        var v3_direction = transform.position - target.position;
        dd.DealDamage(damage, -v3_direction, knck);
    }
}
