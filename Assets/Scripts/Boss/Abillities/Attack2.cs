using ParticleData;
using ProjectilePoolObject;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Attack2 : Abillity
{
    private LogicBoss lgcBoss;
    private IGenericAbillityRequests abillityRequests;
    private AnimationComms animComms;

    [SerializeField] float leapRange;
    [SerializeField] float projectileSpd;
    [SerializeField] GameObject spikes;

    void OnEnable()
    {
        if (lgcBoss == null || animComms == null || abillityRequests == null)
        {
            lgcBoss = transform.parent.parent.TryGetComponent(out LogicBoss lb) ? lb : null;
            abillityRequests = transform.parent.parent.TryGetComponent(out IGenericAbillityRequests ab) ? ab : null;
            animComms = transform.parent.parent.GetComponentInChildren<AnimationComms>();
            if (lgcBoss == null || animComms == null || abillityRequests == null) { Debug.LogError($"Missing scripts on {this.name}!"); return; }
        }
    }

    public override void AnimEvents(int index)
    {
        switch(index)
        {
            default:
                Debug.LogError("No AnimEvents index!");
                break;
            case 0:
                lgcBoss.CanLookBeforeAttack(false);
                var int_randomDir = Random.Range(0, 2);
                var flt_randomRange = Random.Range(1f, 5f);
                if (int_randomDir == 0) abillityRequests.RequestMovement(lgcBoss.GetBossTransform().forward * flt_randomRange, 5f, 5f, false, null);
                else abillityRequests.RequestMovement(lgcBoss.GetBossTransform().forward * (-flt_randomRange), 5f, 5f, false, null);
                //Debug.Log(int_randomDir);
                break;
            case 1:
                abillityRequests.RequestStopMovement();
                break;
            case 2:
                int collideLayer = LayerMask.GetMask("Hurtbox");
                ProjectileCapsuleColliderStat colliderStat = new ProjectileCapsuleColliderStat(new Vector3(0f, 2.0f, 0f), 2.0f, 1f, true, collideLayer);
                ProjectileStat projectileStat0 = new ProjectileStat(lgcBoss.GetBossTransform(), transform.forward, 5f, projectileSpd, power, 10f);
                ProjectileStat projectileStat1 = new ProjectileStat(lgcBoss.GetBossTransform(), -transform.forward, 5f, projectileSpd, power, 10f);
                ProjectilePoolManager.instance.GetProjectile(projectileStat0, colliderStat, spikes);
                ProjectilePoolManager.instance.GetProjectile(projectileStat1, colliderStat, spikes);
                ParticleRequestParams param = new ParticleRequestParams(ParticleTypes.EXPLOSION, lgcBoss.GetBossTransform().position, Vector3.zero, new Vector3(2f, 2f, 2f), lgcBoss.GetBossTransform(), false);
                ParticlesVFXManager.instance.RequestParticleVFX(param);
                break;
            case 3:
                AttackEnds();
                break;
        }
    }


    public override void AttackEnds()
    {
        lgcBoss.AttackEnds();
    }


    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)BossAnimEnums.ATTACK2, 0, 0f, true, false);
    }
}
